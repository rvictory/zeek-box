#!/usr/bin/python
# -*- coding:utf-8 -*-
import os
import json
import urllib
import urllib.request
import RPi.GPIO as GPIO
from signal import pause
import signal
import time
#picdir = os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), 'pic')
#libdir = os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), 'lib')
#sys.path.append("./lib/")

import logging
from waveshare_epd import epd2in7
import time
from PIL import Image,ImageDraw,ImageFont
import traceback

from gpiozero import Button

with open('/opt/waveshare/pid', 'w', encoding='utf-8') as f:
    f.write(str(os.getpid()))

zeek_start_time = time.time()
zeek_finish_time = time.time()
is_zeek_recording = False

btn1 = Button(5)                              # assign each button to a variable
btn2 = Button(6)                              # by passing in the pin number
btn3 = Button(13)                             # associated with the button
btn4 = Button(19)                             #

def handleBtnPress(btn):
    global is_zeek_recording
    global zeek_start_time
    global zeek_finish_time
    pinNum = btn.pin.number
    print("Received button press from {}".format(str(pinNum)))
    if pinNum == 5:
        rotate_vpn()
    elif pinNum == 6:
        if not is_zeek_recording:
            print("Starting Zeek Recording")
            zeek_start_time = int(time.time())
            is_zeek_recording = True
            print_ip_info()
        else:
            print("Stopping Zeek Recording")
            zeek_finish_time = int(time.time())
            is_zeek_recording = False
            dump_zeek()
    elif pinNum == 19:
        printToDisplay("Rebooting the system")
        os.system("reboot now")

logging.basicConfig(level=logging.DEBUG)

def dump_zeek():
    printToDisplay("Creating Zeek Report...")
    print("ruby /opt/collector/collector.rb /opt/zeek_logs {}-{} > /opt/zeek_logs/report.txt".format(zeek_start_time, zeek_finish_time))
    os.system("ruby /opt/collector/collector.rb /opt/zeek_logs {}-{} > /opt/zeek_logs/report.txt".format(zeek_start_time, zeek_finish_time))
    print_ip_info()

def printToDisplay(string):
    epd = epd2in7.EPD()
    epd.init()
    epd.Clear(0xFF)
    font24 = ImageFont.truetype(os.path.join(os.path.dirname(os.path.realpath(__file__)), "resources/Font.ttc"), 24)
    Himage = Image.new('1', (epd.height, epd.width), 255)  # 255: clear the frame
    draw = ImageDraw.Draw(Himage)
    draw.text((10, 60), string, font = font24, fill = 0)
    epd.display(epd.getbuffer(Himage))
    epd.sleep()

def rotate_vpn():
    printToDisplay("Rotating VPN...")
    os.system("ruby /opt/utils/rotate_vpn.rb us")
    time.sleep(10)
    print_ip_info()

def print_ip_info():
    epd = epd2in7.EPD()
    epd.init()
    epd.Clear(0xFF)
    try:
        ip_info = json.load(urllib.request.urlopen("https://ipinfo.io/"))
    except:
        printToDisplay("Couldn't retrieve external IP")
        return
    try:
        #logging.info("epd2in7 Demo")

        '''2Gray(Black and white) display'''
        #logging.info("init and Clear")
        #epd.Clear(0xFF)
        font24 = ImageFont.truetype(os.path.join(os.path.dirname(os.path.realpath(__file__)), "resources/Font.ttc"), 24)
        font18 = ImageFont.truetype(os.path.join(os.path.dirname(os.path.realpath(__file__)), "resources/Font.ttc"), 18)
        font12 = ImageFont.truetype(os.path.join(os.path.dirname(os.path.realpath(__file__)), "resources/Font.ttc"), 12)
        font35 = ImageFont.truetype(os.path.join(os.path.dirname(os.path.realpath(__file__)), "resources/Font.ttc"), 35)
        # Drawing on the Horizontal image
        #logging.info("1.Drawing on the Horizontal image...")
        Himage = Image.new('1', (epd.height, epd.width), 255)  # 255: clear the frame
        draw = ImageDraw.Draw(Himage)
        draw.text((10, 0), 'External IP: ' + ip_info["ip"], font = font18, fill = 0)
        draw.text((10, 20), '' + ip_info["city"] + ", " + ip_info["region"], font = font18, fill = 0)
        draw.text((10, 40), "Country: " + ip_info["country"], font=font18, fill=0)
        draw.text((10, 130), "SSID: " + str(os.environ['SSID']), font=font12, fill=0)
        draw.text((10, 145), "Password: " + str(os.environ['WPA_PASSPHRASE']) + "   ", font=font12, fill=0)
        if is_zeek_recording:
            draw.text((250, 145), "Z   ", font=font12, fill=0)

        #draw.line((20, 50, 70, 100), fill = 0)
        #draw.line((70, 50, 20, 100), fill = 0)
        #draw.rectangle((20, 50, 70, 100), outline = 0)
        #draw.line((165, 50, 165, 100), fill = 0)
        #draw.line((140, 75, 190, 75), fill = 0)
        #draw.arc((140, 50, 190, 100), 0, 360, fill = 0)
        #draw.rectangle((80, 50, 130, 100), fill = 0)
        #draw.chord((200, 50, 250, 100), 0, 360, fill = 0)
        epd.display(epd.getbuffer(Himage))
        #time.sleep(2)

        #logging.info("Clear...")
        #epd.Clear(0xFF)
        #logging.info("Goto Sleep...")
        epd.sleep()

    except IOError as e:
        logging.info(e)

btn1.when_pressed = handleBtnPress
btn2.when_pressed = handleBtnPress
btn3.when_pressed = handleBtnPress
btn4.when_pressed = handleBtnPress

def refresh_signal_handler(sig, frame):
    print_ip_info()

signal.signal(signal.SIGUSR1, refresh_signal_handler)

try:
    print_ip_info()
    pause()
except KeyboardInterrupt:
    logging.info("ctrl + c:")
    epd2in7.epdconfig.module_exit()
    exit()