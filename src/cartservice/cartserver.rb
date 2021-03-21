#!/usr/bin/env ruby

require 'grpc'
require 'redis'
require_relative './Cart_services_pb'

include Hipstershop


class ServerImpl < CartService::Service
  def initialize
    @redis = Redis.new(url: ENV['REDIS_ADDR'])
  end

  def add_item(req, _call)
    if cart = @redis.get(req.user_id)
      cart = Cart.decode_json(cart)

      if found = cart.items.find { |i| i.product_id == req.item.product_id }
        found.quantity += req.item.quantity
      else
        cart.items << req.item
      end
    else
      cart = Cart.new(user_id: req.user_id, items: [req.item])
    end

    @redis.set(req.user_id, Cart.encode_json(cart))
  end

  def get_cart(req, _call)
    if cart = @redis.get(req.user_id)
      Cart.decode_json(cart)
    else
      Cart.new(user_id: req.user_id)
    end
  end

  def empty_cart(req, _call)
    @redis.del(req.user_id)
  end
end

def main
  s = GRPC::RpcServer.new
  s.add_http2_port("#{ENV['LISTEN_ADDR']}:#{ENV['PORT']}", :this_port_is_insecure)
  GRPC.logger.info("... running")
  s.handle(ServerImpl.new)
  s.run_till_terminated_or_interrupted([1, 'int', 'SIGQUIT'])
end

main
