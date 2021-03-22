FROM ruby:2.7.2

WORKDIR /app
COPY Gemfile* .
RUN bundle install

COPY . .

ENTRYPOINT ["bundle", "exec", "ruby", "cartservice.rb"]
