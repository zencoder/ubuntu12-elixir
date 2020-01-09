# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# @trenpixster wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return
# ----------------------------------------------------------------------------

FROM ubuntu:18.04
MAINTAINER Adam Kittelson @adamkittelson

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT 2020-01-09

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...

# Set the locale
RUN apt-get clean && apt-get update && apt-get install -y locales gnupg2
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /tmp

RUN echo $(openssl version)

# See : https://github.com/phusion/baseimage-docker/issues/58
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN echo "deb http://packages.erlang-solutions.com/ubuntu bionic contrib" >> /etc/apt/sources.list && \
  apt-key adv --fetch-keys http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc && \
  apt-get -qq update && apt-get install -y \
  esl-erlang=1:22.2.1-1 \
  git \
  unzip \
  build-essential \
  wget && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download and Install Specific Version of Elixir
WORKDIR /elixir
RUN wget -q https://github.com/elixir-lang/elixir/releases/download/v1.10.0-rc.0/Precompiled.zip && \
  unzip Precompiled.zip && \
  rm -f Precompiled.zip && \
  ln -s /elixir/bin/elixirc /usr/local/bin/elixirc && \
  ln -s /elixir/bin/elixir /usr/local/bin/elixir && \
  ln -s /elixir/bin/mix /usr/local/bin/mix && \
  ln -s /elixir/bin/iex /usr/local/bin/iex

# Install local Elixir hex and rebar
RUN /usr/local/bin/mix local.hex --force && \
  /usr/local/bin/mix local.rebar --force

WORKDIR /
