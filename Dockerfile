FROM ubuntu:focal

RUN apt-get update && apt-get install -y gpg curl && \
    echo 'deb http://download.opensuse.org/repositories/security:/zeek/Raspbian_11/ /' | tee /etc/apt/sources.list.d/security:zeek.list && \
    curl -fsSL https://download.opensuse.org/repositories/security:zeek/Raspbian_11/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null && \
    echo 'deb http://download.opensuse.org/repositories/security:/zeek/xUbuntu_22.04/ /' | tee /etc/apt/sources.list.d/security:zeek.list && \
    curl -fsSL https://download.opensuse.org/repositories/security:zeek/xUbuntu_22.04/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq zeek-lts && \
    echo 'LogAscii::use_json=T;' >> /opt/zeek/share/zeek/site/local.zeek

RUN apt-get install -y ruby-full

# hostapd stuff taken from https://github.com/offlinehacker/docker-ap/blob/master/Dockerfile
RUN apt-get install -y bash hostapd iptables dhcpd iproute2 iw && curl -sSL https://get.docker.com | sh
RUN echo "" > /var/lib/dhcp/dhcpd.leases
ADD wlanstart.sh /bin/wlanstart.sh

#ENTRYPOINT [ "/bin/wlanstart.sh" ]