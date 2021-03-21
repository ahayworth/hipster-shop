This is a fork of a [fork](https://github.com/lightstep/hipster-shop) of https://github.com/GoogleCloudPlatform/microservices-demo

# Hipster Shop: OpenTelemetry Observability Demo Application

- [Service Architecture](#service-architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
  - [Local Installation Only](#local-installation-only)
  - [All Installations](#all-installations)
- [Local Installation](#local-installation)
- [Cleanup](#cleanup)
- [Conferences featuring Hipster Shop](#conferences-featuring-hipster-shop)


The application is a web-based e-commerce app called **Hipster Shop** where users can browse items,
add them to the cart, and purchase them. Google originally used this application to demonstrate use of technologies like
Kubernetes/GKE, Istio, Stackdriver, gRPC and OpenCensus.

This fork uses it to demonstrate OpenTelemetry, Grafana, Loki, Tempo, and related technologies.

This project contains a 10-tier microservices application, where services are built using different languages and different tracing libraries. It runs with a simple `docker-compose up`, making it easy to get started!

If you’re using this demo, please **★Star** this repository to show your interest!


| Home Page                                                                                                         | Checkout Page                                                                                                    |
| ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [![Screenshot of store homepage](/docs/img/home-page.png)](./docs/img/hipster-shop-frontend-1.png) | [![Screenshot of checkout screen](./docs/img/checkout-page.png)](./docs/img/hipster-shop-frontend-2.png) |

## Service Architecture

**Hipster Shop** is composed of many microservices written in different
languages that talk to each other over gRPC.

[![Architecture of
microservices](./docs/img/architecture-diagram.png)](./docs/img/architecture-diagram.png)

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

## Features

- **[OpenTelemetry](https://opentelemetry.lightstep.com/) Tracing:** Most services are instrumented using OpenTelemetry trace interceptors for gRPC/HTTP.
- **[Grafana](TODO)**
- **[Tempo](TODO)**
- **[Loki](TODO)**
- **Synthetic Load Generation:** The application demo comes with a background
  job that creates realistic usage patterns on the website using
  [Locust](https://locust.io/) load generator.

## Prerequisites

### Local Installation Only
Install one of the following two options to run a Kubernetes cluster locally for this demo:
   - [Docker for Desktop](https://www.docker.com/products/docker-desktop).

## Local Installation
**Time to install**: About 20 minutes

You will build and deploy microservices images to a single-node Kubernetes cluster running on your development machine.

Use one of the following for you cluster:
- Docker for Desktop (recommended for Mac/Windows)
- Docker

7. In a browser, visit http://localhost:80. You should see the home page where you can shop for donuts and coffee.
    ![Hipster Shop home page](/docs/img/home-page.png)

## Cleanup

- If you want to run this demo again, just run `docker-compose down` to clean up.
- If you want to remove it entirely, then run `docker-compose down --volumes --rmi all` to remove all data volumes and images.

## Conferences Featuring Hipster Shop

- [Google Cloud Next'18 London – Keynote](https://youtu.be/nIq2pkNcfEI?t=3071)
  showing Stackdriver Incident Response Management
- Google Cloud Next'18 SF
  - [Day 1 Keynote](https://youtu.be/vJ9OaAqfxo4?t=2416) showing GKE On-Prem
  - [Day 3 – Keynote](https://youtu.be/JQPOPV_VH5w?t=815) showing Stackdriver
    APM (Tracing, Code Search, Profiler, Google Cloud Build)
  - [Introduction to Service Management with Istio](https://www.youtube.com/watch?v=wCJrdKdD6UM&feature=youtu.be&t=586)
- [KubeCon EU 2019 - Reinventing Networking: A Deep Dive into Istio's Multicluster Gateways - Steve Dake, Independent](https://youtu.be/-t2BfT59zJA?t=982)

---

This is not an official Google project.



TODO:
- better installation docs
- Talk about UIs available
- Expose ports to localhost for dev work!
- dozzle
