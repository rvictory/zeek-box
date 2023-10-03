#!/bin/bash

iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j REDIRECT --to-port 8080 -m comment --comment "mitmproxy"
iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 443 -j REDIRECT --to-port 8080 -m comment --comment "mitmproxy"