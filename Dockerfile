FROM ubuntu:focal

RUN apt update && apt install -y gpg curl && \
    echo 'deb http://download.opensuse.org/repositories/security:/zeek/xUbuntu_22.04/ /' | tee /etc/apt/sources.list.d/security:zeek.list && \
    curl -fsSL https://download.opensuse.org/repositories/security:zeek/xUbuntu_22.04/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null

RUN apt update #&& \
    #apt install -y zeek-lts && \
    #echo 'LogAscii::use_json=T;' >> /opt/zeek/share/zeek/site/local.zeek

#RUN apt install -y ruby-full
