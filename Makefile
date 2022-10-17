build:
	git pull
	sudo docker build -t zeek_box .

run:
	mkdir -p /home/pi/zeek_logs
	mkdir -p /home/pi/zeek-box/open_vpn_conf_files
	sudo docker kill zeek_box_instance || true
	sudo docker rm zeek_box_instance || true
	sudo docker run -d \
        -e INTERFACE=wlan0 \
        -e OUTGOINGS=eth0 \
        -e HT_CAPAB=[HT40][SHORT-GI-20][DSSS_CCK-40] \
        -v/home/pi/zeek_logs:/opt/zeek_logs \
        -v/home/pi/zeek-box/open_vpn_conf_files:/opt/openvpn \
        -v/home/pi/zeek-box/open_vpn_conf_files/auth.txt:/etc/openvpn/auth.txt \
        -e OPEN_VPN_CONF_FILE=/opt/openvpn/us2853.nordvpn.com.udp1194.ovpn \
        --net host --privileged --rm --name zeek_box_instance zeek_box /bin/bash

stop:
	sudo docker kill zeek_box_instance

logs:
	sudo docker logs zeek_box_instance