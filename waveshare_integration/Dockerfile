FROM ubuntu:focal

RUN apt-get update && apt-get -y install python3-rpi.gpio python-dev wget gcc make wiringpi git && \
    cd /opt && wget http://www.airspayce.com/mikem/bcm2835/bcm2835-1.71.tar.gz && \
    tar zxvf bcm2835-1.71.tar.gz && cd bcm2835-1.71/ && ./configure && make && make check && make install

RUN apt-get update && \
    apt-get install -y python3-pip python3-pil python3-numpy && \
    pip3 install RPi.GPIO && \
    pip3 install spidev

ADD . /opt/waveshare/


