##############################################################################
# GLOBAL VARIABLES
#
# Variables used both in build and runtime stages. You can override these
# variables from docker-compose.yml or from the command lijne
#https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact

# The version of Alpine to use for the final image
# This should match the version of Alpine that the `elixir:1.10-alpine` image uses
ARG ALPINE_VERSION=3.11

ARG APP_NAME=hello
ARG APP_DIR=/opt/app
ARG APP_USER=app
ARG MIX_ENV=prod


##############################################################################
# BUILD STAGE
#
# Sets up the build environment. Installs a few additional build tools such as Node.js
# Builds the application, including the assets.

FROM elixir:1.10-alpine AS builder

ARG APP_DIR
ARG MIX_ENV

ENV \
  MIX_ENV=${MIX_ENV} \
  APP_DIR=${APP_DIR}

# Install build tools
RUN \
  apk update \
  && apk upgrade --no-cache --update \
  && apk add --no-cache yarn git \
  && mix local.rebar --force \
  && mix local.hex --force

WORKDIR ${APP_DIR}

# Copy sources
COPY . .

# Get and compile dependencies, compile the application
RUN mix do deps.get --only ${MIX_ENV}, deps.compile, compile

# Install js dependencies and then build the assets
RUN \
  cd assets \
  && yarn install \
  && yarn build-prod \
  && cd - \
  && mix phx.digest

# Create the release
RUN mix release


##############################################################################
# RUNTIME STAGE
#
# Creates the actual runtime image from scratch. To keep the image as compact as
# possible we won't install Erlang Runtime Libraries since it is already included
# in the release created in the Build Stage.
FROM alpine:${ALPINE_VERSION}

ARG APP_NAME
ARG APP_USER
ARG APP_DIR
ARG MIX_ENV

ENV \
  LANG=C.UTF-8 \
  TERM=xterm \
  TZ=Europe/Warsaw \
  PS1A="docker:\[\$(tput setaf 2)\]\$(pwd)\[\$(tput sgr0)\]:\[\$(tput setaf 3)\]kxwidget-\$MIX_ENV\[\$(tput sgr0)\]\$ "

RUN echo "export PS1=\$PS1A" >> ~/.bashrc

RUN \
  apk update \
  && apk upgrade --no-cache --update \
  && apk add --no-cache bash curl \
  && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
  && echo $TZ > /etc/timezone

RUN \
  addgroup --system ${APP_USER} \
  && adduser --system --home /home/${APP_USER} ${APP_USER} \
  && addgroup ${APP_USER} ${APP_USER}

RUN \
  mkdir -p ${APP_DIR} \
  && chown ${APP_USER}:${APP_USER} ${APP_DIR}

WORKDIR ${APP_DIR}

# Do not run as root
USER ${APP_USER}

EXPOSE ${HTTP_PORT}

# Copy the release created in the Build Stage
COPY --from=builder --chown=${APP_USER}:${APP_USER} ${APP_DIR}/_build/${MIX_ENV}/rel/${APP_NAME}/ .
COPY ./secrets .

# Set up runtime environment
ENV \
  LOG_PATH=${APP_DIR}/log \
  HTTP_PORT=8080 \
  HTTPS_PORT=8443 \
  SERVER_CERTFILE=${APP_DIR}/jackal.pw.crt \
  SERVER_KEYFILE=${APP_DIR}/jackal.pw.key \
#  HOST=localhost \
#  RELEASE_DISTRIBUTION=none \
#  RELEASE_NODE=elixr@elixir \
  SECRET_KEY_BASE=XwkLekxMaHijVecozKRk8RdtiM4nYQCHSwY8kP5WgUyla1S1Pfrg5cnHh3R3xsVN

# Start the application
CMD ["bin/hello", "start"]
