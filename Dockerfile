FROM ruby:3.1.1-alpine
RUN apk add --update --virtual \
    runtime-deps \
    mysql-dev \
    build-base \
    libxml2-dev \
    libxslt-dev \
    nodejs \
    yarn \
    readline \
    libc-dev \
    linux-headers \
    readline-dev \
    file \
    git \
    tzdata \
    && rm -rf /var/cache/apk/*

WORKDIR /server
COPY /server /server
ADD . /server/
ADD /server/Gemfile /codeapp/
ADD /server/Gemfile.lock /codeapp/

ENV BUNDLE_PATH /gems
RUN yarn install
RUN bundle install

ENTRYPOINT [ "bin/rails" ]
CMD ["s", "-b", "0.0.0.0"]

EXPOSE 3000