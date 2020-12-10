FROM ubuntu:16.04

ARG GIT_TAG

ENV ARDUINO_VERSION="1.8.13"
ENV ARDUINO_ESP_VERSION="2.7.4"
ENV GIT_TAG=${GIT_TAG}

RUN apt-get update -qq && apt-get install -qq -y --no-install-recommends -f software-properties-common \
  && add-apt-repository ppa:openjdk-r/ppa \
  && apt-get update \
  && apt-get install --no-install-recommends --allow-change-held-packages -y \
  wget \
  zip \
  unzip \
  git \
  make \
  srecord \
  bc \
  xz-utils \
  gcc \
  curl \
  xvfb \
  python \
  python-pip \
  python-dev \
  build-essential \
  libncurses-dev \
  flex \
  bison \
  gperf \
  python-serial \
  libxrender1 \
  libxtst6 \
  libxi6 \
  openjdk-8-jre \
  jq \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /opt

RUN curl https://downloads.arduino.cc/arduino-$ARDUINO_VERSION-linux64.tar.xz > ./arduino-$ARDUINO_VERSION-linux64.tar.xz \
 && unxz -q ./arduino-$ARDUINO_VERSION-linux64.tar.xz \
 && tar -xvf arduino-$ARDUINO_VERSION-linux64.tar \
 && rm -rf arduino-$ARDUINO_VERSION-linux64.tar \
 && mv ./arduino-$ARDUINO_VERSION ./arduino \
 && cd ./arduino \
 && ./install.sh

WORKDIR /opt/arduino/hardware/espressif

RUN git clone https://github.com/espressif/arduino-esp32.git esp32

WORKDIR /opt/arduino/hardware/espressif/esp32
RUN git submodule update --init --recursive \
 && rm -rf ./**/examples/**

WORKDIR /opt/arduino/hardware/espressif/esp32/tools
RUN python get.py

WORKDIR /opt/arduino/hardware/espressif
RUN git clone https://github.com/esp8266/Arduino.git esp8266
WORKDIR /opt/arduino/hardware/espressif/esp8266
RUN git checkout tags/$ARDUINO_ESP_VERSION \
  && rm -rf ./**/examples/**

WORKDIR /opt/arduino/hardware/espressif/esp8266/tools
RUN python get.py

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN mkdir /opt/workspace
WORKDIR /opt/workspace
COPY cmd.sh /opt/
CMD [ "/opt/cmd.sh" ]
