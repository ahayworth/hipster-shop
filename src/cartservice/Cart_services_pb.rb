# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: Cart.proto for package 'hipstershop'
# Original file comments:
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'grpc'
require_relative './Cart_pb'

module Hipstershop
  module CartService
    # -----------------Cart service-----------------
    #
    class Service

      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'hipstershop.CartService'

      rpc :AddItem, ::Hipstershop::AddItemRequest, ::Hipstershop::Empty
      rpc :GetCart, ::Hipstershop::GetCartRequest, ::Hipstershop::Cart
      rpc :EmptyCart, ::Hipstershop::EmptyCartRequest, ::Hipstershop::Empty
    end

    Stub = Service.rpc_stub_class
  end
end
