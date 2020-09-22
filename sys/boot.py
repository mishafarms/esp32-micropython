import sys
import uos
import gc
import webrepl
from lib import wifi
from lib import panel

gc.collect()

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
