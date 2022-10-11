#!/usr/bin/env bash

# Update everything
sudo apt update && sudo apt upgrade -y
sudo apt install -y git vim

git clone https://github.com/rvictory/zeek-box

# Install Docker
curl -sSL https://get.docker.com | sh

# Build the Docker Image
sudo docker build -t zeek_box .