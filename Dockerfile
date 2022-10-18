FROM ubuntu:focal

RUN apt-get update && apt-get install -y gpg curl && \
    echo 'deb http://download.opensuse.org/repositories/security:/zeek/xUbuntu_20.04/ /' | tee /etc/apt/sources.list.d/security:zeek.list && \
    curl -fsSL https://download.opensuse.org/repositories/security:zeek/xUbuntu_20.04/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq zeek-lts

# hostapd stuff taken from https://github.com/offlinehacker/docker-ap/blob/master/Dockerfile
#RUN apt-get install -y bash hostapd iptables isc-dhcp-server iproute2 iw rfkill net-tools && curl -sSL https://get.docker.com | sh
RUN apt-get install -y hostapd dnsmasq iptables net-tools rfkill iw bash
ADD wlanstart.sh /bin/wlanstart.sh
ADD collector/ /opt/collector/

RUN apt-get install -y ruby-full
# OpenVPN
RUN apt-get install -y openvpn wget vim
ADD start.sh /bin/start.sh
ADD utils/ /opt/utils/

RUN apt-get update && apt-get -y install python3-rpi.gpio python-dev wget gcc make wiringpi git
    #cd /opt && wget http://www.airspayce.com/mikem/bcm2835/bcm2835-1.71.tar.gz
    #tar zxvf bcm2835-1.71.tar.gz && cd bcm2835-1.71/ && ./configure && make && make check && make install

RUN apt-get update && \
    apt-get install -y python3-pip python3-pil python3-numpy && \
    pip3 install RPi.GPIO && \
    pip3 install spidev && \
    cd /opt/ && git clone https://github.com/waveshare/e-Paper/ && \
    cd e-Paper/RaspberryPi_JetsonNano/python && pip3 install .

ADD ./waveshare_integration /opt/waveshare/

# Default WAP info
ENV SSID private
ENV WPA_PASSPHRASE passw0rd

ENTRYPOINT [ "/bin/start.sh" ]