ARG base_image=ghcr.io/alphagov/govuk-ruby-base:3.1.2
ARG builder_image=ghcr.io/alphagov/govuk-ruby-builder:3.1.2

FROM $builder_image AS builder

RUN apt update && \
    apt install -y wget

WORKDIR /app

COPY Gemfile* .ruby-version /app/

RUN bundle config set without 'development test webkit' && \
    bundle install

RUN wget -O /etc/ssl/certs/rds-combined-ca-bundle.pem https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem

COPY . /app


FROM $base_image

ENV GOVUK_APP_NAME=router-api

WORKDIR /app

RUN ln -fs /tmp /app/tmp

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app /app/
COPY --from=builder /etc/ssl/certs/rds-combined-ca-bundle.pem /etc/ssl/certs/rds-combined-ca-bundle.pem

USER app

CMD bundle exec puma
