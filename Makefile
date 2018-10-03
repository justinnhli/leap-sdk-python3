PREFIX := $(if $(PREFIX),$(PREFIX),/usr)
PYTHON3_VERSION := $(shell python3 --version | cut -d' ' -f 2 | cut -d. -f 1,2)
ARCH := $(shell uname -m | sed -e 's/x86_64/x64/')

SDK_PATH=./leap/LeapSDK

LeapPython.so: Leap.py
	g++ -fPIC -I/usr/include/python$(PYTHON3_VERSION)m -I$(SDK_PATH)/include LeapPython.cpp $(SDK_PATH)/lib/$(ARCH)/libLeap.so -shared -o LeapPython.so

Leap.py: leap
	swig -c++ -python -o LeapPython.cpp -interface LeapPython $(SDK_PATH)/include/Leap.i

leap: LeapSDK.tar.gz Leap.i.diff
	mkdir -p leap
	tar xvf LeapSDK.tar.gz -C leap --strip-components 1
	patch -p0 < Leap.i.diff

LeapSDK.tar.gz:
	wget -O LeapSDK.tar.gz http://warehouse.leapmotion.com/apps/4185/download/

clean:
	rm -rf __pycache__
	rm -rf leap
	rm -f LeapPython.cpp
	rm -f LeapPython.h
	rm -f LeapPython.so
	rm -f Leap.py
	rm -f LeapSDK.tar.gz

install:
	mkdir -p $(PREFIX)/lib/python$(PYTHON3_VERSION)/site-packages/
	install -m 0644 Leap.py $(PREFIX)/lib/python$(PYTHON3_VERSION)/site-packages/Leap.py
	install -m 0755 LeapPython.so $(PREFIX)/lib/python$(PYTHON3_VERSION)/site-packages/LeapPython.so
	install -m 0755 $(SDK_PATH)/lib/$(ARCH)/libLeap.so $(PREFIX)/lib/libLeap.so

uninstall:
	rm -f $(PREFIX)/lib/python$(PYTHON3_VERSION)/site-packages/Leap.py
	rm -f $(PREFIX)/lib/python$(PYTHON3_VERSION)/site-packages/LeapPython.so
	rm -f $(PREFIX)/lib/libLeap.so
