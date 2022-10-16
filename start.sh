#!/bin/bash -e

# Start up the Wireless Access Point
#/bin/wlanstart.sh

# Default values
true ${INTERFACE:=wlan0}
true ${SUBNET:=192.168.220.0}
true ${AP_ADDR:=192.168.220.1}
true ${SSID:=docker-ap}
true ${CHANNEL:=11}
true ${WPA_PASSPHRASE:=passw0rd}
true ${HW_MODE:=g}
true ${DRIVER:=nl80211}
true ${HT_CAPAB:=[HT40-][SHORT-GI-20][SHORT-GI-40]}
true ${MODE:=host}

#systemctl stop hostapd
#systemctl stop dnsmasq

#cat > "/etc/dhcpd.conf" <<EOF
#interface wlan0
#    static ip_address=${AP_ADDR}/24
#   nohook wpa_supplicant
#EOF

#systemctl restart dhcpcd


cat > "/etc/hostapd.conf" <<EOF
interface=${INTERFACE}
driver=${DRIVER}
ssid=${SSID}
hw_mode=${HW_MODE}
channel=${CHANNEL}
macaddr_acl=0
ignore_broadcast_ssid=0

auth_algs=1
wpa=2
wpa_passphrase=${WPA_PASSPHRASE}
wpa_key_mgmt=WPA-PSK
# TKIP is no secure anymore
#wpa_pairwise=TKIP CCMP
wpa_pairwise=CCMP
rsn_pairwise=CCMP
#wpa_ptk_rekey=600
ieee80211n=1
ht_capab=${HT_CAPAB}
wmm_enabled=0
EOF

mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
cat > "/etc/dnsmasq.conf" <<EOF
interface=${INTERFACE} # Use interface
server=1.1.1.1       # Use Cloudflare DNS
dhcp-range=192.168.220.50,192.168.220.150,12h # IP range and lease time
EOF

ifconfig ${INTERFACE} down
ifconfig ${INTERFACE} up
rfkill unblock wlan

ip link set ${INTERFACE} up
ip addr flush dev ${INTERFACE}
ip addr add ${AP_ADDR}/24 dev ${INTERFACE}

sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

service dnsmasq start
/usr/sbin/hostapd -B -f ~/hostapd.log /etc/hostapd.conf &

# Start Zeek TODO: need to configure zeekctl to use wlan0
#/opt/zeek/bin/zeekctl start

# Configure the VPN iptables rules
#iptables -F
#iptables -t nat -F
#iptables -X
#iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
#iptables-nft -C FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT || iptables-nft -A FORWARD -i tun0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
#iptables-nft -C FORWARD -i wlan0 -o tun0 -j ACCEPT || iptables-nft -A FORWARD -i wlan0 -o tun0 -j ACCEPT

# Start the VPN
#openvpn --config $OPEN_VPN_CONF_FILE
