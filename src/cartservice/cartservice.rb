require 'bundler/setup'
Bundler.require
require_relative './Cart_services_pb'

class CartServer < Hipstershop::CartService::Service
  def initialize
    @redis = Redis.new(url: ENV['REDIS_ADDR'])
  end

  def add_item(req, _call)
    if cart = @redis.get(req.user_id)
      cart = Hipstershop::Cart.decode_json(cart)

      if found = cart.items.find { |i| i.product_id == req.item.product_id }
        found.quantity += req.item.quantity
      else
        cart.items << req.item
      end
    else
      cart = Hipstershop::Cart.new(user_id: req.user_id, items: [req.item])
    end

    cart = Hipstershop::Cart.encode_json(cart)
    @redis.set(req.user_id, cart)

    return Hipstershop::Empty.new
  end

  def get_cart(req, _call)
    if cart = @redis.get(req.user_id)
      Hipstershop::Cart.decode_json(cart)
    else
      Hipstershop::Cart.new(user_id: req.user_id)
    end
  end

  def empty_cart(req, _call)
    @redis.del(req.user_id)
    return Hipstershop::Empty.new
  end
end

class HeaderWrapper
  def initialize(metadata)
    @metadata = metadata
  end

  def [](key)
    @metadata[key.downcase]
  end

  def keys
    @metadata.keys
  end
end

class OpenTelemetryInterceptor < GRPC::ServerInterceptor
  def initialize
    OpenTelemetry::SDK.configure do |c|
      c.add_span_processor(
        OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
          OpenTelemetry::Exporter::OTLP::Exporter.new(
            endpoint: ENV['OTEL_EXPORTER_OTLP_TRACES_ENDPOINT'],
          )
        )
      )
      c.use_all
      c.service_name = ENV['LS_SERVICE_NAME']
    end

    @tracer = OpenTelemetry.tracer_provider.tracer
  end

  def request_response(request: nil, call: nil, method: nil)
    service_name = call.service_name
    method_name  = method.name

    parent_context = ::OpenTelemetry.propagation.extract(HeaderWrapper.new(call.metadata))

    span_attrs = {
      'rpc.system'  => 'grpc',
      'rpc.service' => service_name.to_s,
      'rpc.method'  => method_name.to_s,
    }

    @tracer.in_span("#{service_name}/#{method_name}", kind: :server, attributes: span_attrs, with_parent: parent_context) do |span|
      yield(request, call)
    end
  end
end

STDOUT.sync = true
Griffin::Server.configure do |c|
  c.bind ENV['LISTEN_ADDR']
  c.port ENV['PORT']
  c.services CartServer.new
  c.interceptors [OpenTelemetryInterceptor.new]
  c.workers 4
end

Griffin::Server.run
