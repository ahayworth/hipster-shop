# Hipster Shop: OpenTelemetry Observability Demo Application

- [Service Architecture](#service-architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Cleanup](#cleanup)
- [Conferences featuring Hipster Shop](#conferences-featuring-hipster-shop)

**Hipster Shop** is a comprehensive OpenTelemetry technology demo and reference application. It features a functional e-commerce site built on a collection of microservices, all instrumented with OpenTelemetry. You can browse the site, add items to your cart, and even "purchase" them - demonstrating the complete vision of modern distributed telemetry.

We demonstrate the following technologies:

- OpenTelemetry Tracing, Metrics, and Logging
- The OpenTelemetry Collector
- Grafana, Loki (logs storage), and Tempo (trace storage)
- Prometheus

Our goal is to provide a sample microservice in each official OpenTelemetry language, instrumented with the very latest that language's SDK has to offer. When a language's OpenTelemetry SDK does not provide one of the three telemetry pillars (Tracing, Metrics, and Logging), we provide a modern and useful alternative that can fill the gap until that language's SDK support improves.

This application is based on the excellent work done by Google in their [microservices-demo](https://github.com/GoogleCloudPlatform/microservices-demo) and LightStep in their [hipster-shop](https://github.com/lightstep/hipster-shop) - we're grateful for their work, and hope to collaborate on demo applications in the future.

![demo](https://user-images.githubusercontent.com/1781907/114475187-64f78780-9bbd-11eb-9df1-1bd1a753f924.gif)


## Service Architecture

**Hipster Shop** is composed of many microservices written in different
languages that talk to each other over gRPC.

Find **Protocol Buffers Descriptions** at the [`./pb` directory](./pb).

| Service                                              | Language      | Description                                                                                                                       |
| ---------------------------------------------------- | ------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| [frontend](./src/frontend)                           | Go            | Exposes an HTTP server to serve the website. Does not require signup/login and generates session IDs for all users automatically. |
| [cartservice](./src/cartservice)                     | Ruby          | Stores the items in the user's shopping cart in Redis and retrieves it.                                                           |
| [productcatalogservice](./src/productcatalogservice) | Go            | Provides the list of products from a JSON file and ability to search products and get individual products.                        |
| [currencyservice](./src/currencyservice)             | Node.js       | Converts one money amount to another currency. Uses real values fetched from European Central Bank. It's the highest QPS service. |
| [paymentservice](./src/paymentservice)               | Node.js       | Charges the given credit card info (mock) with the given amount and returns a transaction ID.                                     |
| [shippingservice](./src/shippingservice)             | Go            | Gives shipping cost estimates based on the shopping cart. Ships items to the given address (mock)                                 |
| [emailservice](./src/emailservice)                   | Python        | Sends users an order confirmation email (mock).                                                                                   |
| [checkoutservice](./src/checkoutservice)             | Go            | Retrieves user cart, prepares order and orchestrates the payment, shipping and the email notification.                            |
| [recommendationservice](./src/recommendationservice) | Python        | Recommends other products based on what's given in the cart.                                                                      |
| [adservice](./src/adservice)                         | Java          | Provides text ads based on given context words.                                                                                   |
| [loadgenerator](./src/loadgenerator)                 | Python/Locust | Continuously sends requests imitating realistic user shopping flows to the frontend.                                              |

## Prerequisites

You'll need a working docker and docker-compose setup. On a Mac or PC, we recommend [Docker for Desktop](https://www.docker.com/products/docker-desktop). On linux, we recommend your distribution's docker package.

## Installation

**Time to install**: 20 minutes or so

Installation is simple - from the root of this repository, simply run `docker-compose up`.

Then, in a browser, visit http://localhost:80. You should see the home page where you can shop for donuts and coffee.
You can visit http://localhost:3000 to see your telemetry!

## Cleanup

- If you want to run this demo again, just run `docker-compose down` to clean up.
- If you want to remove it entirely, then run `docker-compose down --volumes --rmi all` to remove all data volumes and images.

## Roadmap

Here's what we're planning to work on next:

- [ ] Re-writing services to remove LightStep-specific code, so that we can demonstrate native initialization with the OpenTelemetry SDKs.
- [ ] Re-writing some services in other languages - we wish to demonstrate every language SDK supported by OpenTelemetry.
- [ ] Demonstrating technologies other than GRPC
- [ ] Demonstrating various auto-instrumentation techniques
- [ ] Adding native logging and metrics support to all examples, as those specifications mature
- [ ] Pre-configuring Grafana dashboards to monitor the demonstration
- [ ] Enhanced correlation of metrics signals (traces -> logs, logs -> metrics, etc)
- [ ] Experimental OpenTelemetry features, such as metrics auto-configuration.
- [ ] Multiple installation / distribution methods (kubernetes cluster, etc)
- [ ] Demonstrate how to use the collector to switch out telemetry backends

We'd love your help!
