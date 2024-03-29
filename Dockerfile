FROM ubuntu:focal

RUN apt-get update && apt-get install -y gpg curl && \
    echo 'deb http://download.opensuse.org/repositories/security:/zeek/xUbuntu_20.04/ /' | tee /etc/apt/sources.list.d/security:zeek.list && \
    curl -fsSL https://download.opensuse.org/repositories/security:zeek/xUbuntu_20.04/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq zeek-lts

# hostapd stuff taken from https://github.com/offlinehacker/docker-ap/blob/master/Dockerfile
#RUN apt-get install -y bash hostapd iptables isc-dhcp-server iproute2 iw rfkill net-tools && curl -sSL https://get.docker.com | sh
RUN apt-get install -y hostapd dnsmasq iptables net-tools rfkill iw bash

RUN apt-get install -y ruby-full
# OpenVPN
RUN apt-get install -y openvpn wget vim

RUN apt-get update && apt-get -y install python3-rpi.gpio python-dev wget gcc make wiringpi git
    #cd /opt && wget http://www.airspayce.com/mikem/bcm2835/bcm2835-1.71.tar.gz
    #tar zxvf bcm2835-1.71.tar.gz && cd bcm2835-1.71/ && ./configure && make && make check && make install

RUN apt-get update && \
    apt-get install -y python3-pip python3-pil python3-numpy mitmproxy && \
    pip3 install RPi.GPIO && \
    pip3 install spidev && \
    pip3 install gpiozero && \
    cd /opt/ && git clone https://github.com/waveshare/e-Paper/ && \
    cd e-Paper/RaspberryPi_JetsonNano/python && pip3 install . && \
    mkdir /opt/web_ui/

ADD collector/ /opt/collector/
RUN gem install bundler && cd /opt/collector && bundle install

ADD web_ui/Gemfile /opt/web_ui/Gemfile
RUN cd /opt/web_ui && bundle install

ADD wlanstart.sh /bin/wlanstart.sh
ADD ./waveshare_integration /opt/waveshare/
ADD start.sh /bin/start.sh
ADD enable_mitmproxy.sh /bin/enable_mitmproxy.sh
ADD disable_mitmproxy.sh /bin/disable_mitmproxy.sh
ADD utils/ /opt/utils/
ADD mitmproxy/ /opt/mitmproxy/
ADD web_ui/ /opt/web_ui/

# Default WAP info
ENV SSID private
ENV WPA_PASSPHRASE passw0rd

ENTRYPOINT [ "/bin/start.sh" ]