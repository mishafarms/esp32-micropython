# ESP32 MicroPython

Very rough install guide...
## Requirements

    Node.js (with `yarn` if building)
    Python 3.7
    esptool.py (`pip3 install esptool`)
## Environment

Need to discover port path on your system. Typically examples:

For macOS:

    export ESPTOOL_PORT=/dev/cu.SLAB_USBtoUART

For Windows (use Device Manager to discover the actual port number):

    export ESPTOOL_PORT=COM3

For Linux (the default):

    export ESPTOOL_PORT=/dev/ttyUSB0
## Quick Install

    cd ~/src
    git clone https://github.com/mishafarms/esp32-micropython.git
    cd esp32-micropython
    export ESPTOOL_PORT=/dev/ttyUSB0 (Windows:ESPTOOL_PORT=COM3)
    (plug in the Esp32)
    yarn run flash-merged
## Full Build
#### Clone Archives 
    (git clone all arcives to the ~/src folder)
	cd ~/src
	git clone https://github.com/mishafarms/esp32-micropython.git
	git clone https://github.com/mishafarms/edublocks-micropython.git
	git clone https://github.com/mishafarms/micropython.git
	git clone https://github.com/mishafarms/OttoDIYPython.git
	export ESPTOOL_PORT=/dev/ttyUSB0
#### Build panel-web-app

	cd ~/src/esp32-micropython/panel
	yarn
	yarn run build
#### Build EduBlocks

	cd ~/src/edublocks-micropython
	yarn
	yarn run build
#### Build Micropython

	cd ~/src/esp32-micropython
 	yarn
	yarn run build-mp (if you get an error run indented lines)
		cd ~/src/micropython/ports/esp32/
		git config --global --add safe.directory /opt/esp/idf/components/openthread/openthread
		make BOARD=WROVER_16M submodules
		cd ~/src/esp32-micropython
	yarn run build-mp (if you get an error run indented line)
		yarn install
	yarn run build-mp		
#### Bundle assets

	cd ~/src/esp32-micropython
	yarn
	yarn run mount-sys-linux         # Or: yarn run mount-sys-osx
	yarn run bundle
	yarn run bundle-otto
	yarn run umount-sys-linux        # Or: yarn run umount-sys-osx
	yarn run merge
#### Flash on to ESP32

	cd ~/src/esp32-micropython
	yarn run flash-erase (Optional)
	yarn run flash-merged

