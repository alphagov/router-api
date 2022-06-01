ARG base_image=ruby:2.7.6-slim-buster

FROM $base_image AS builder

ENV RAILS_ENV=production

# TODO: have a separate build image which already contains the build-only deps.
RUN apt-get update -qq && \
    apt-get upgrade -y && \
    apt-get install -y build-essential nodejs wget && \
    apt-get clean

RUN mkdir /app

WORKDIR /app
COPY Gemfile* .ruby-version /app/

RUN bundle config set deployment 'true' && \
    bundle config set without 'development test webkit' && \
    bundle install -j8 --retry=2

RUN wget -O /etc/ssl/certs/rds-combined-ca-bundle.pem https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem

COPY . /app


FROM $base_image

ENV GOVUK_PROMETHEUS_EXPORTER=true RAILS_ENV=production GOVUK_APP_NAME=router-api

RUN apt-get update -qy && \
    apt-get upgrade -y && \
    apt-get install -y nodejs && \
    apt-get clean



COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app /app/
COPY --from=builder /etc/ssl/certs/rds-combined-ca-bundle.pem /etc/ssl/certs/rds-combined-ca-bundle.pem 

WORKDIR /app

CMD bundle exec puma
