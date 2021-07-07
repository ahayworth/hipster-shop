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

STDOUT.sync = true

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

server = GRPC::RpcServer.new
server.add_http2_port("#{ENV['LISTEN_ADDR']}:#{ENV['PORT']}", :this_port_is_insecure)
server.handle(CartServer.new)
server.run_till_terminated_or_interrupted([1, 'int', 'SIGQUIT'])
