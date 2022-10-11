#!/usr/bin/env bash

# Update everything
sudo apt update && sudo apt upgrade -y
sudo apt install -y git vim


# Install Docker
curl -sSL https://get.docker.com | sh

# Build the Docker Image
sudo docker build -t zeek_box .