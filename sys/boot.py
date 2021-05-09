import sys
import uos
import gc
import webrepl
from lib import mountPart
from lib import wifi
from lib import panel
import time
from machine import TouchPad
from machine import Pin

gc.collect()

time.sleep_ms(150)
wifi.auto_connect()

gc.collect()

webrepl.start(password='')

gc.collect()

panel.start_panel()

gc.collect()

sys.path.append('/user')

touch = TouchPad(Pin(14))

if touch.read() > 500 :
    try:
        import main
    except:
        print('Could not find main start up script')
else:
    print("Skipping main.py")
