#!/bin/bash -e

# TODO: see https://serverfault.com/questions/991217/iptables-drop-all-non-vpn-packets-exiting-the-eth0-access-point
# Start up the Wireless Access Point
#/bin/wlanstart.sh

set -eE -o functrace
failure() {
  local lineno=$1
  local msg=$2
  echo "Failed at $lineno: $msg"
}
trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

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

ip addr flush dev ${INTERFACE}
ifconfig ${INTERFACE} down
ifconfig ${INTERFACE} up
rfkill unblock wlan

ip link set ${INTERFACE} up
ip addr flush dev ${INTERFACE}
ip addr add ${AP_ADDR}/24 dev ${INTERFACE}

sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

#iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

echo "Starting dnsmasq"
service dnsmasq start
echo "Starting hostapd"
/usr/sbin/hostapd -B -f ~/hostapd.log /etc/hostapd.conf &

# Start Zeek
mkdir -p /opt/zeek_logs
cd /opt/zeek_logs
echo "Starting Zeek"
/opt/zeek/bin/zeek -i wlan0 'LogAscii::use_json=T;' &

#iptables -F
#iptables -t nat -F
#iptables -X

# Set iptables default to drop everything
#iptables -P OUTPUT DROP
#iptables -P INPUT DROP
#iptables -P FORWARD DROP

# Allow SSH to still work over eth0 (https://serverfault.com/questions/425493/anonymizing-openvpn-allow-ssh-access-to-internal-server)
echo "Setting RT Table"
echo "201 novpn" >> /etc/iproute2/rt_tables
echo "Adding fwmark ip rule"
ip rule add fwmark 65 table novpn
echo "Adding novpn route"
! ip route add default via 192.168.3.1 dev eth0 table novpn || true # TODO this shouldn't use a hard-coded IP
echo "Flushing the route cache"
ip route flush cache
echo "Adding the iptables rule to tag the traffic"
iptables -t mangle -A OUTPUT -p tcp --sport 22 -j MARK --set-mark 65
iptables -t mangle -A OUTPUT -p tcp --sport 8081 -j MARK --set-mark 65
iptables -t mangle -A OUTPUT -p tcp --sport 4567 -j MARK --set-mark 65

# Start mitmproxy
/usr/bin/mitmweb --mode transparent --set web_iface=0.0.0.0 -s /opt/mitmproxy/addon.py &

# Start the VPN
echo "Starting OpenVPN"
#groupadd -r openvpn
#openvpn --config $OPEN_VPN_CONF_FILE --daemon
ruby /opt/utils/rotate_vpn.rb

# See https://security.stackexchange.com/questions/183177/openvpn-kill-switch-on-linux/183361#183361
#iptables -A OUTPUT -j ACCEPT -m owner --gid-owner openvpn
# The loopback device is harmless, and TUN is required for the VPN.
#iptables -A OUTPUT -j ACCEPT -o lo
#iptables -A OUTPUT -j ACCEPT -o tun+

# We should permit replies to traffic we've sent out.
#iptables -A INPUT -j ACCEPT -m state --state ESTABLISHED

# Configure the VPN iptables rules
echo "Configuring VPN rules so wlan0 goes out tun0"
iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
iptables-nft -C FORWARD -i tun0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT || iptables-nft -A FORWARD -i tun0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables-nft -C FORWARD -i wlan0 -o tun0 -j ACCEPT || iptables-nft -A FORWARD -i wlan0 -o tun0 -j ACCEPT

# Never let wlan0 traffic out of eth0
# TODO use variables
iptables-nft -C FORWARD -i wlan0 -o eth0 -j DROP || iptables-nft -A FORWARD -i wlan0 -o eth0 -j DROP

iptables -A INPUT -i tun0 -p tcp -m tcp --dport 22 -j DROP

# mitmproxy
/bin/enable_mitmproxy.sh

# Start the eInk display
python3 /opt/waveshare/eink_info.py &

# Start the Web UI
ruby /opt/web_ui/server.rb &

echo "Complete, looping indefinitely"
while true; do sleep 1; done;

# We want to still be able to SSH to the box even with OpenVPN turned on (https://serverfault.com/questions/659955/allowing-ssh-on-a-server-with-an-active-openvpn-client)
# set "connection" mark of connection from eth0 when first packet of connection arrives
#iptables -t mangle -A PREROUTING -i eth0 -m conntrack --ctstate NEW -j CONNMARK --set-mark 1234
# set "firewall" mark for response packets in connection with our connection mark
#iptables -t mangle -A OUTPUT -m connmark --mark 1234 -j MARK --set-mark 4321
# our routing table with eth0 as gateway interface
#ip route add default dev eth0 table 3412
# route packets with our firewall mark using our routing table
#ip rule add fwmark 4321 table 3412

