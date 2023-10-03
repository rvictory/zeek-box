#!/bin/bash

iptables-save | grep -v "mitmproxy" | iptables-restore