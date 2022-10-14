# ZeekBox (until I have a better name)
**Synopsis**: an all in one traffic analysis and capture box specifically designed for OPSEC management during malware analysis, especially on a physical
phone (iPhone or Android device).

My vision for this project looks something like this:
* Runs on a Raspberry Pi
* Connected to the internet over Ethernet
* Starts a wifi access point that goes through a VPN (or list of VPNs that can be cycled through)
* Runs Zeek (and Suricata?) listening to the wifi before the vpn
* A few buttons (and maybe a LCD) on the physical device
* One button says “start capture” and the other says “finish capture”
* Basically before you run some malware you hit  start and when you’re done you hit finish
* After a capture, a script gathers up the Zeek logs and other info for that session and sends it to you in a report
* Other useful options in the future, such as automatic mitmproxy 
* Useful Android tools such as Frida if you connect the device over USB

Essentially, let's say I have some malware (or potential malware) on an Android phone, but that malware has anti-analysis
capabilities. I can connect my phone to the ZeekBox, which will provide a VPN protected connection (masking my true IP
address) without the device itself having a VPN configured. Before I execute the malware, I hit the "start capture" button
on the Pi. I run the malware and interact with it. When I'm done, I hit "stop capture." The system then analyzes the logs
and delivers me an email with useful reporting information (summary info) about the session and an attachment with the
Zeek logs (Zip file) and perhaps a full PCAP as well.

## Usage
Bare-bones so far, just testing out how it might work. See `collector.rb` for the basic skeleton

To run the docker container: 

`sudo docker run -i -t -e INTERFACE=wlan0 -e OUTGOINGS=eth0 -e HT_CAPAB=[HT40][SHORT-GI-20][DSSS_CCK-40] --net host --privileged zeek_box`

## Things to use later:
* https://github.com/SebastianJ/nordvpn-api

#### Test Data
Some of the test data (in `tests/data/logs`) has been sourced from https://github.com/brimdata/zed-sample-data and is licensed under the
license terms found in that repository (Creative Commons Attribution-ShareAlike 4.0 International License as of October 9th, 2022)
