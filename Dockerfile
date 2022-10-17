FROM ubuntu:focal

RUN apt-get update && apt-get install -y gpg curl && \
    echo 'deb http://download.opensuse.org/repositories/security:/zeek/xUbuntu_20.04/ /' | tee /etc/apt/sources.list.d/security:zeek.list && \
    curl -fsSL https://download.opensuse.org/repositories/security:zeek/xUbuntu_20.04/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq zeek-lts #&& \
    #echo 'LogAscii::use_json=T;' >> /opt/zeek/share/zeek/site/local.zeek

RUN apt-get install -y ruby-full

# hostapd stuff taken from https://github.com/offlinehacker/docker-ap/blob/master/Dockerfile
#RUN apt-get install -y bash hostapd iptables isc-dhcp-server iproute2 iw rfkill net-tools && curl -sSL https://get.docker.com | sh
RUN apt-get install -y hostapd dnsmasq iptables net-tools rfkill iw bash
#RUN mkdir -p /var/lib/dhcp/ && echo "" > /var/lib/dhcp/dhcpd.leases
ADD wlanstart.sh /bin/wlanstart.sh
ADD collector/ /opt/collector/

# OpenVPN
RUN apt-get install -y openvpn wget vim
ADD start.sh /bin/start.sh

ENTRYPOINT [ "/bin/start.sh" ]