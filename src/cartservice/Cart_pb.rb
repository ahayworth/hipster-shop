# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: Cart.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("Cart.proto", :syntax => :proto3) do
    add_message "hipstershop.CartItem" do
      optional :product_id, :string, 1
      optional :quantity, :int32, 2
    end
    add_message "hipstershop.AddItemRequest" do
      optional :user_id, :string, 1
      optional :item, :message, 2, "hipstershop.CartItem"
    end
    add_message "hipstershop.EmptyCartRequest" do
      optional :user_id, :string, 1
    end
    add_message "hipstershop.GetCartRequest" do
      optional :user_id, :string, 1
    end
    add_message "hipstershop.Cart" do
      optional :user_id, :string, 1
      repeated :items, :message, 2, "hipstershop.CartItem"
    end
    add_message "hipstershop.Empty" do
    end
  end
end

module Hipstershop
  CartItem = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("hipstershop.CartItem").msgclass
  AddItemRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("hipstershop.AddItemRequest").msgclass
  EmptyCartRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("hipstershop.EmptyCartRequest").msgclass
  GetCartRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("hipstershop.GetCartRequest").msgclass
  Cart = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("hipstershop.Cart").msgclass
  Empty = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("hipstershop.Empty").msgclass
end
