FROM ruby:2.4.2
RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y build-essential && apt-get clean
RUN gem install foreman

ENV GOVUK_APP_NAME router-api
ENV MONGODB_URI mongodb://mongo/router
ENV PORT 3056
ENV RAILS_ENV development
ENV ROUTER_NODES router:3055
ENV TEST_MONGODB_URI mongodb://mongo/router-test

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

CMD foreman run web
