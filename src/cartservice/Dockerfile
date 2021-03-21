FROM ruby:2.7.2

WORKDIR /app
COPY Gemfile* .
RUN bundle install

COPY . .

ENTRYPOINT ["/usr/local/bin/ruby", "/app/cartserver.rb"]
