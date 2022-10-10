FROM ubuntu:bionic

RUN echo 'deb http://download.opensuse.org/repositories/security:/zeek/xUbuntu_18.04/ /' | tee /etc/apt/sources.list.d/security:zeek.list && \
    curl -fsSL https://download.opensuse.org/repositories/security:zeek/xUbuntu_18.04/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null && \
    apt update && \
    apt install -y zeek-lts && \
    echo 'LogAscii::use_json=T;' >> /opt/zeek/share/zeek/site/local.zeek #&& \
    #apt install -y ruby-3.0
