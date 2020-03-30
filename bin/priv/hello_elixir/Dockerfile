############################################################
# Dockerfile to build Kontomatik Insight image
############################################################

# !! This must be exactly the same distribution version as on the production server !!
# !! Otherwise Erlang dependencies likely won't match !!
FROM ubuntu:18.04

MAINTAINER api@kontomatik.com

#############################################################
# Installs precompiled esl-erlang package by Erlang Solutions
#############################################################

RUN \
  set -xe \
  && OTP_PACKAGE_NAME="esl-erlang_22.2.7-1~ubuntu~bionic_amd64.deb" \
  && OTP_DOWNLOAD_URL="https://packages.erlang-solutions.com/erlang/debian/pool/${OTP_PACKAGE_NAME}" \
  && apt-get update \
  && installDeps='curl ca-certificates' \
  && apt-get install -y --no-install-recommends $installDeps \
  && runtimeDeps='libodbc1 libsctp1 libwxgtk3.0' \
  && apt-get install -y --no-install-recommends $runtimeDeps \
  && curl -fSL -o "$OTP_PACKAGE_NAME" "$OTP_DOWNLOAD_URL" \
  && dpkg -i "$OTP_PACKAGE_NAME" \
  && rm "$OTP_PACKAGE_NAME"

CMD ["erl"]


############################################################
# Installs precompiled elixir 1.9.4
# Based on official docker image for elixir 1.4
# Source: https://github.com/c0b/docker-elixir/blob/81908da9ecc7de1007d12c764918aa056d03af9b/1.4/Dockerfile
############################################################

# elixir expects utf8.
ENV \
  ELIXIR_VERSION="v1.10.2" \
  LANG=C.UTF-8

RUN \
  set -xe \
  && ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/releases/download/${ELIXIR_VERSION}/Precompiled.zip" \
  && ELIXIR_DOWNLOAD_SHA512="532f43f08a29b5cbfca5a544c337b4a6d336d372ba0a5b3393681426d57ecaa85960e8eb3548aea26f213cc36914c6b66b83707cd719e27dc34c40efadb9f0b9" \
  && buildDeps='unzip' \
  && apt-get install -y --no-install-recommends $buildDeps \
  && curl -fSL -o elixir-precompiled.zip $ELIXIR_DOWNLOAD_URL \
  && echo $ELIXIR_DOWNLOAD_SHA512 elixir-precompiled.zip | sha512sum -c - \
  && unzip -d /usr/local elixir-precompiled.zip \
  && rm elixir-precompiled.zip \
  && apt-get purge -y --auto-remove $buildDeps \
  && rm -rf /var/lib/apt/lists/*

CMD ["iex"]

############################################################
# Configure dev image
############################################################

ENV \
  APP_DIR=/app \
  APP_USER=app

RUN \
  groupadd --system $APP_USER --gid 1000 && useradd --system --gid $APP_USER --uid 1000 $APP_USER && \
  mkdir /home/$APP_USER && \
  chown -R $APP_USER:$APP_USER /home/$APP_USER && \
  mkdir $APP_DIR

# == DEV ======================================================================================================
# The build-essentials are necessary for the next tasks
RUN apt-get update
RUN apt-get install -y build-essential

# add https transport
RUN apt-get install apt-transport-https

# Git is necessary to fetch un-hexed project deps
RUN apt-get install -y git

# Node is necessary to build assets
RUN \
    curl -sL https://deb.nodesource.com/setup_13.x | bash \
    && apt-get install -y nodejs

# add yarn key
RUN \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install YARN
RUN apt-get update
RUN apt-get install yarn

# Dockerize is necessary so app-container can wait for db-container to fully start (start listening on port)
RUN \
    set -xe \
    && DOCKERIZE_PACKAGE_NAME="dockerize-linux-amd64-v0.6.1.tar.gz" \
    && DOCKERIZE_DOWNLOAD_URL="https://github.com/jwilder/dockerize/releases/download/v0.6.1/$DOCKERIZE_PACKAGE_NAME" \
    && curl -o $DOCKERIZE_PACKAGE_NAME -L $DOCKERIZE_DOWNLOAD_URL \
    && tar -C /usr/local/bin -xzvf $DOCKERIZE_PACKAGE_NAME \
    && rm $DOCKERIZE_PACKAGE_NAME

# Inotify is necessary to allow hot reloading (no need to refresh the browser to see html edits)
RUN apt-get install -y inotify-tools postgresql-client
# == /DEV ======================================================================================================

ENV TZ=Europe/Warsaw
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR $APP_DIR

COPY . $APP_DIR

RUN chown -R $APP_USER:$APP_USER $APP_DIR

# Do not run as root
USER $APP_USER

# DEV
RUN \
  mkdir ~/.ssh && \
  echo "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config && \
  echo "Host git.in.kontomatik.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

ENV \
  MIX_ENV=prod \
  HEX_HOME=/home/$APP_USER/.hex \
  HTTP_PORT=8080 \
  HTTPS_PORT=8443 \
  TERM=xterm \
  PS1A="docker:\[\$(tput setaf 2)\]\$(pwd)\[\$(tput sgr0)\]:\[\$(tput setaf 3)\]kxwidget-\$MIX_ENV\[\$(tput sgr0)\]\$ "

RUN \
  echo "Y" | mix local.rebar && \
  echo "Y" | mix local.hex

EXPOSE $HTTP_PORT $HTTPS_PORT

# Start server on container startup
#     mix    do    deps.loadpaths,    phx.server    --no-compile    --no-deps-check
CMD ["mix", "do", "deps.loadpaths,", "phx.server", "--no-compile", "--no-deps-check"]

# Set bash prompt
RUN echo "export PS1=\$PS1A" >> ~/.bashrc
