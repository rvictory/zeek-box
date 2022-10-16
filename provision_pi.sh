#!/usr/bin/env bash

# Update everything
sudo apt update && sudo apt upgrade -y
sudo apt install -y git vim

git clone https://github.com/rvictory/zeek-box

# Install Docker
curl -sSL https://get.docker.com | sh

# Need to add automation to make systemd not listen on port 53, for now follow:
# https://www.linuxuprising.com/2020/07/ubuntu-how-to-free-up-port-53-used-by.html

# Build the Docker Image
sudo docker build -t zeek_box .