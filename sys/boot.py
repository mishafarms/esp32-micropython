import sys
import uos
import gc
import webrepl
from lib import wifi
from lib import panel
import time

gc.collect()

time.sleep_ms(150)
wifi.auto_connect()

gc.collect()

webrepl.start(password='')

gc.collect()

panel.start_panel()

gc.collect()

sys.path.append('/user')

try:
    import main
except:
    print('Could not find main start up script')
