PREFIX := $(if $(PREFIX),$(PREFIX),/usr)

PY_VERSION := $(shell python3 -c 'import sys; print("{}.{}".format(*sys.version_info[:2]))')
PY_PATH := $(shell python3 -c 'import sys; from os.path import realpath; print(realpath(realpath(sys.executable) + "/../.."))')

PLATFORM := $(shell uname)
ARCH := $(shell uname -m | sed -e 's/x86_64/x64/')
ifeq ($(PLATFORM), Linux)
  OBJ_FILE=libLeap.so
  OBJ_PATH=$(ARCH)/$(OBJ_FILE)
else
  OBJ_FILE=libLeap.dylib
  OBJ_PATH=$(OBJ_FILE)
endif

ifeq ($(PLATFORM), Linux)
  SDK_URL=http://warehouse.leapmotion.com/apps/4185/download
else
  SDK_URL=https://warehouse.leapmotion.com/apps/4181/download
endif
SDK_PATH=./leap-sdk/LeapSDK

LeapPython.so: Leap.py
	g++ -fPIC -lpython$(PY_VERSION) -I$(PY_PATH)/include/python$(PY_VERSION)m -I$(SDK_PATH)/include -L$(PY_PATH)/lib LeapPython.cpp $(SDK_PATH)/lib/$(OBJ_PATH) -shared -o LeapPython.so

Leap.py: leap-sdk
	swig -c++ -python -o LeapPython.cpp -interface LeapPython $(SDK_PATH)/include/Leap.i

leap-sdk: LeapSDK.tgz Leap.i.diff
	mkdir -p leap-sdk
	tar -C leap-sdk --strip-components 1 -xf LeapSDK.tgz 
	patch -p0 < Leap.i.diff

LeapSDK.tgz:
	wget -O LeapSDK.tgz $(SDK_URL)

clean:
	rm -rf __pycache__
	rm -rf leap-sdk
	rm -f LeapSDK.tgz
	rm -f LeapPython.cpp
	rm -f LeapPython.h
	rm -f Leap.py
	rm -f LeapPython.so
	rm -f Sample.py

install:
	mkdir -p $(PY_PATH)/lib/python$(PY_VERSION)/site-packages/
	install -m 0755 $(SDK_PATH)/lib/$(OBJ_PATH) $(PREFIX)/lib/$(OBJ_FILE)
	install -m 0755 LeapPython.so $(PY_PATH)/lib/python$(PY_VERSION)/site-packages/LeapPython.so
	install -m 0644 Leap.py $(PY_PATH)/lib/python$(PY_VERSION)/site-packages/Leap.py

Sample.py:
	2to3 $(SDK_PATH)/samples/Sample.py

test: Sample.py
	python3 Sample.py

uninstall:
	rm -f $(PY_PATH)/lib/python$(PY_VERSION)/site-packages/Leap.py
	rm -f $(PY_PATH)/lib/python$(PY_VERSION)/site-packages/LeapPython.so
	rm -f $(PREFIX)/lib/$(OBJ_FILE)
