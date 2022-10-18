#!/usr/bin/python
# -*- coding:utf-8 -*-
import os
import json
import urllib
import urllib.request
#picdir = os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), 'pic')
#libdir = os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), 'lib')
#sys.path.append("./lib/")

import logging
from waveshare_epd import epd2in7
import time
from PIL import Image,ImageDraw,ImageFont
import traceback

logging.basicConfig(level=logging.DEBUG)

ip_info = json.load(urllib.request.urlopen("https://ipinfo.io/"))

try:
    #logging.info("epd2in7 Demo")
    epd = epd2in7.EPD()

    '''2Gray(Black and white) display'''
    #logging.info("init and Clear")
    epd.init()
    epd.Clear(0xFF)
    font24 = ImageFont.truetype(os.path.join(os.path.dirname(os.path.realpath(__file__)), "resources/Font.ttc"), 24)
    font18 = ImageFont.truetype(os.path.join(os.path.dirname(os.path.realpath(__file__)), "resources/Font.ttc"), 18)
    font35 = ImageFont.truetype(os.path.join(os.path.dirname(os.path.realpath(__file__)), "resources/Font.ttc"), 35)
    # Drawing on the Horizontal image
    #logging.info("1.Drawing on the Horizontal image...")
    Himage = Image.new('1', (epd.height, epd.width), 255)  # 255: clear the frame
    draw = ImageDraw.Draw(Himage)
    draw.text((10, 0), 'External IP: ' + ip_info["ip"], font = font18, fill = 0)
    draw.text((10, 20), '' + ip_info["city"] + ", " + ip_info["region"], font = font18, fill = 0)
    draw.text((10, 40), "Country: " + ip_info["country"], font=font18, fill=0)
    draw.text((10, 120), "SSID: " + str(os.environ['SSID']), font=font18, fill=0)
    draw.text((10, 140), "Password: " + str(os.environ['WPA_PASSPHRASE']), font=font18, fill=0)
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

except KeyboardInterrupt:
    logging.info("ctrl + c:")
    epd2in7.epdconfig.module_exit()
    exit()