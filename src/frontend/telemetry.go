package main

import (
	"context"
	"net/url"
	"os"
	"time"

	"go.opentelemetry.io/contrib/propagators/b3"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp"
	"go.opentelemetry.io/otel/exporters/otlp/otlpgrpc"
	"go.opentelemetry.io/otel/metric/global"
	"go.opentelemetry.io/otel/propagation"
	controller "go.opentelemetry.io/otel/sdk/metric/controller/basic"
	processor "go.opentelemetry.io/otel/sdk/metric/processor/basic"
	"go.opentelemetry.io/otel/sdk/metric/selector/simple"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

// Initializes an OTLP exporter, and configures the corresponding
// trace and metric providers. We return a function that should be
// called before your application shuts down, to ensure that metrics
// and traces are flushed appropriately and resources cleaned up.
func initTelemetry() (func(), error) {
	ctx := context.Background()

	// The OpenTelemetry specification indicates that you can configure
	// language SDKs with environmental variables. We wish to use the
	// OTLP exporter over GRPC, with an insecure connection. Per the
	// spec, that should correspond to just:
	//
	//   OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:port
	//
	// At the moment, the go SDK does not support configuration via
	// environment variables. We are parsing this URL to obtain just
	// the host:port combo to pass in the SDK initialization.
	// That way, once the go SDK is spec-compliant in this area, we
	// can simply remove this parsing/explicit configuration and the
	// SDK can auto-configure itself based on the environment vars:
	//
	//   driver := otlpgrpc.NewDriver()
	//
	// https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/protocol/exporter.md
	// https://github.com/open-telemetry/opentelemetry-go/issues/1085
	endpoint, err := url.Parse(os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT"))
	if err != nil {
		return nil, err
	}

	driver := otlpgrpc.NewDriver(
		otlpgrpc.WithEndpoint(endpoint.Host),
		otlpgrpc.WithInsecure(),
	)

	// The go OTLP exporter can also support OTLP over http/json, which
	// is why setting up the exporter is a 2-step process - we must first
	// choose the protocol we want, and then set up the exporter with it.
	exporter, err := otlp.NewExporter(ctx, driver)
	if err != nil {
		return nil, err
	}

	// The go SDK will autodetect these resource attributes:
	//
	//   - default attributes representing the go SDK itself
	//   - attributes from the host we're running on
	//   - attributes defined in the OTEL_RESOURCE_ATTRIBUTES env var
	//
	// If we wanted, we could also specify additional "detectors"
	// here to pick up different resource attributes; override the
	// defaults, or even specify our own manually. See the docs
	// for a description of the interface.
	// https://pkg.go.dev/go.opentelemetry.io/otel/sdk/resource
	resource, err := resource.New(ctx)
	if err != nil {
		return nil, err
	}

	// We use the BatchSpanProcessor - which is generally recommended
	// for production or production-like environments.
	batchSpanProcessor := sdktrace.NewBatchSpanProcessor(exporter)

	// The OpenTelemetry SDK allows you to have multiple "tracer
	// providers", which can have different configurations. This is
	// something of an implementation detail for most smaller apps,
	// but is useful for large applications that may wish to trace
	// some portions differently than others. We just set up one.
	tracerProvider := sdktrace.NewTracerProvider(
		sdktrace.WithResource(resource),
		sdktrace.WithSpanProcessor(batchSpanProcessor),

		// In this environment, we always want all of our traces.
		// In the future, sampling can be set in the environment:
		// https://github.com/open-telemetry/opentelemetry-go/issues/1698
		sdktrace.WithSampler(sdktrace.AlwaysSample()),
	)

	// We make this tracer provider available as the global default.
	otel.SetTracerProvider(tracerProvider)

	// Next, we set up our tracing context propagation, so that our
	// traces are nicely linked together across systems. We actually
	// want to set up multiple propagators:
	//
	// - B3, for compatibility with the Jaeger ecosystem
	//   TODO: Should we stop doing that?
	// - W3C TraceContext, for compatibility within OpenTelemetry and
	//   for general forward compatibility with other tracing systems
	// - W3C Baggage, primarily for future compatibility.
	//
	// To do that, we construct a "composite" propagator that handles
	// all of these formats transparently. In the future, we will be
	// able to configure this via the environment:
	//
	//   https://github.com/open-telemetry/opentelemetry-go/issues/1698
	//
	// Note: There are other propagators you may wish to consider in your
	//       own system for interoperability - such as the OpenTracing
	//       propagator, which the go SDK also supports.
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
		b3.B3{},
		propagation.TraceContext{},
		propagation.Baggage{},
	))

	// Now we set up our metrics controller - this orchestrates the
	// overall metrics export pipeline. Unlike traces (which are not
	// typically generated if there is no activity), the OpenTelemetry
	// specification allows for asynchronously observed metrics. Hence,
	// the need for a supervisor of sorts which coordinates that activity.
	metricsController := controller.New(
		// The processor handles actually 'checkpointing' (eg: taking a
		// snapshot) of the metric values for export, handles aggregation,
		// and handles any necessary transforms required by the desired
		// export protocol.
		processor.New(
			// There are other options - 'Inexact' and 'Histogram', at the moment.
			simple.NewWithExactDistribution(),
			// We pass our desired exporter, so that the processor can make
			// whatever transformations are required for that export method.
			exporter,
		),
		// The controller will use our OTLP exporter, pushing metrics to
		// the collector. One common alternative here would be a Prometheus
		// exporter, which would be a pull-based model that you could configure.
		controller.WithExporter(exporter),
		// You could control how often you would like metrics to be pushed
		// to the collector, based on whatever your production system requires.
		controller.WithCollectPeriod(2*time.Second),
	)

	// We will use a global meter for recording metrics, for simplicity.
	// Multiple meter controllers (and their associated meter providers)
	// can co-exist in an application, if you desire. The global object
	// is simply a convenience that is useful in most applications.
	global.SetMeterProvider(metricsController.MeterProvider())

	err = metricsController.Start(ctx)
	if err != nil {
		return nil, err
	}

	return func() {
		controllerErr := metricsController.Stop(ctx)
		if controllerErr != nil {
			log.Errorf("Failed to stop metrics controller!")
		}

		tracerErr := tracerProvider.Shutdown(ctx)
		if tracerErr != nil {
			log.Errorf("Failed to stop tracer!")
		}
	}, nil

	// TODO: OTEL_LOG_LEVEL
	// TODO: Metrics config service
}
