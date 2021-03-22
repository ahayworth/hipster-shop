require 'bundler/setup'
require_relative './Cart_services_pb'

class CartServiceServer < Hipstershop::CartService::Service
  def add_item(request, _)
    product_id = request.item.product_id

    if cart = redis.get(request.user_id)
      cart = Cart.decode_json(cart)

      if found = cart.items.find { |i| i.product_id == product_id }
        found.quantity += request.item.quantity
      else
        cart.items << request.item
      end
    else
      cart = Cart.new(user_id: request.user_id, items: [request.item])
    end

    redis.set(request.user_id, Cart.encode_json(cart))
  end

  def get_cart(request, _)
    if cart = redis.get(request.user_id)
      Cart.decode_json(cart)
    else
      Cart.new(user_id: request.user_id)
    end
  end

  def empty_cart(request, _)
    redis.del(request.user_id)
  end

  private
  def redis
    @redis ||= Redis.new(url: ENV['REDIS_ADDR'])
  end
end

class OpenTelemetryInterceptor < GRPC::ServerInterceptor
  def initialize
    ::OpenTelemetry::SDK.configure do |c|
      c.add_span_processor(
        ::OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
          ::OpenTelemetry::Exporter::OTLP::Exporter.new(
            endpoint: ENV['OTEL_EXPORTER_OTLP_TRACES_ENDPOINT'],
          )
        )
      )
      c.use_all
    end

    @tracer = ::OpenTelemetry.tracer_provider.tracer(ENV['LS_SERVICE'])
  end

  def request_response(request: nil, call: nil, method: nil)
    service_name = call.service_name
    method_name  = method.name

    parent_context = ::OpenTelemetry.context.extract(call.metadata)

    @tracer.in_span("#{service_name}/#{method_name}", kind: :server, with_parent: parent_context) do
      yield
    end
  end
end

Griffin::Server.configure do |c|
  c.bind ENV['LISTEN_ADDR']
  c.port ENV['PORT']
  c.services CartServiceServer.new
  c.interceptors [OpenTelemetryInterceptor.new]
  c.workers 2
end
