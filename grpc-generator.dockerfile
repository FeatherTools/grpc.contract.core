# Dockerfile for generating PHP gRPC classes with both client and server code
# docker build -f ./grpc-generator.dockerfile -t grpc-php-generator .

FROM composer:2.8.5 AS composer

FROM php:8.5-alpine AS grpc-builder

RUN apk --no-cache add \
  git \
  autoconf \
  automake \
  make \
  cmake \
  curl \
  libtool \
  unzip \
  gcc \
  g++ \
  pkgconfig \
  linux-headers

WORKDIR /github/grpc

RUN git clone --depth 1 https://github.com/grpc/grpc . && \
  git submodule update --init --recursive

ARG MAKEFLAGS=-j8

WORKDIR /github/grpc/cmake/build

RUN cmake ../.. && \
  make protoc grpc_php_plugin

# Final image for generation
FROM php:8.5-alpine

RUN apk --no-cache add \
  git \
  unzip \
  libzip-dev \
  linux-headers

# Install PHP extensions
RUN docker-php-ext-install sockets

# Copy composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Copy protoc and grpc_php_plugin
COPY --from=grpc-builder /github/grpc/cmake/build/third_party/protobuf/protoc \
  /usr/local/bin/protoc

COPY --from=grpc-builder /github/grpc/cmake/build/grpc_php_plugin \
  /usr/local/bin/protoc-gen-grpc

# Install RoadRunner CLI (includes protoc-gen-php-grpc)
WORKDIR /tmp
RUN composer require spiral/roadrunner-cli:^2.7 spiral/roadrunner-grpc:^3.5 google/protobuf:^4.33 && \
  ln -s /tmp/vendor/bin/rr /usr/local/bin/rr

# Create symlink for RoadRunner's protoc plugin
RUN rr download-protoc-binary && \
  find /tmp -name "protoc-gen-php-grpc" -type f -exec ln -s {} /usr/local/bin/protoc-gen-php-grpc \;

WORKDIR /workspace

CMD ["/bin/sh"]
