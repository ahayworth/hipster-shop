module github.com/lightstep/hipster-shop/frontend

go 1.14

require (
	github.com/GoogleCloudPlatform/microservices-demo v0.1.4
	github.com/golang/protobuf v1.4.3
	github.com/google/uuid v1.1.4
	github.com/gorilla/mux v1.8.0
	github.com/pkg/errors v0.9.1
	github.com/sirupsen/logrus v1.6.0
	go.opentelemetry.io/contrib/instrumentation/github.com/gorilla/mux/otelmux v0.19.0
	go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc v0.19.0
	go.opentelemetry.io/contrib/propagators v0.19.0
	go.opentelemetry.io/otel v0.19.0
	go.opentelemetry.io/otel/exporters/otlp v0.19.0
	go.opentelemetry.io/otel/metric v0.19.0
	go.opentelemetry.io/otel/sdk v0.19.0
	go.opentelemetry.io/otel/sdk/metric v0.19.0
	go.opentelemetry.io/otel/trace v0.19.0
	golang.org/x/net v0.7.0
	google.golang.org/grpc v1.36.0
)
