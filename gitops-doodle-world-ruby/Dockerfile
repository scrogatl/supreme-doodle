# Dockerfile

FROM ruby:3.0.2

WORKDIR /world-ruby
COPY src /world-ruby
RUN bundle install

EXPOSE 5003

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "5003"]