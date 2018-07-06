import sys
sys.path.append('/usr/local/lib/python2.7/site-packages')
import serial
import subprocess

port = '/dev/cu.usbserial-A50285BI'

s = serial.Serial(port)  # open serial port
print("opening serial port " + s.name)         # check which port was really used

def sendkeys(string):
    cmd = "tell application \"System Events\"\nkeystroke \"%s\"\nkey code 48\nkey code 36\nend" % string
    subprocess.call(['osascript', '-e', cmd])

while True:
    card_number = s.readline().strip()
    if len(card_number)>1:
        print(card_number)
        sendkeys(card_number)
