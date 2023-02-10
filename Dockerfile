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
ENV REFRESHED_AT 2023-08-02

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

RUN apt-get -qq update && apt-get install -y \
  git \
  unzip \
  build-essential \
  wget \
  libncurses5-dev \
  libncursesw5-dev \
  autoconf \
  openssl \
  libssl-dev \
  fop \
  xsltproc \
  unixodbc-dev \
  curl && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget https://raw.githubusercontent.com/kerl/kerl/master/kerl && \
  chmod a+x kerl && \
  mv kerl /usr/local/bin/

RUN kerl build 22.3.4.25 22.3.4.25
RUN kerl install 22.3.4.25 /bin/22.3.4.25
RUN . /bin/22.3.4.25/activate
ENV PATH=/bin/22.3.4.25/lib/erl_interface-3.13.2.2/bin:/bin/22.3.4.25/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Download and Install Specific Version of Elixir
WORKDIR /elixir
RUN wget -q https://github.com/elixir-lang/elixir/releases/download/v1.10.2/Precompiled.zip && \
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
