'use strict';

const opentelemetry = require('@opentelemetry/api');
const { ConsoleLogger } = require('@opentelemetry/core');
const { NodeTracerProvider } = require('@opentelemetry/node');
const { registerInstrumentations } = require("@opentelemetry/instrumentation");
const { SimpleSpanProcessor } = require('@opentelemetry/tracing');
const { CollectorTraceExporter } =  require('@opentelemetry/exporter-collector');
const { B3MultiPropagator } = require('@opentelemetry/propagator-b3');

opentelemetry.propagation.setGlobalPropagator(new B3MultiPropagator())

module.exports = (serviceName) => {
  opentelemetry.diag.setLogger(new opentelemetry.DiagConsoleLogger(), opentelemetry.DiagLogLevel.DEBUG);

  const provider = new NodeTracerProvider();

  registerInstrumentations({
    tracerProvider: provider,
  });
  provider.register();

  const exporter = new CollectorTraceExporter({
    serviceName: serviceName,
    url: process.env.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT,
  });
  provider.addSpanProcessor(new SimpleSpanProcessor(exporter));

  return opentelemetry.trace.getTracer('currencyservice');
};
