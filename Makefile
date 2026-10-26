THEOS = /Users/runner/theos
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = -

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PubgOverlay

PubgOverlay_FILES = Tweak.x
PubgOverlay_CFLAGS = -fobjc-arc

THEOS_MAKE_PATH = /Users/runner/theos/makefiles
include $(THEOS_MAKE_PATH)/tweak.mk
CC = clang
CXX = clang++
include $(THEOS_MAKE_PATH)/package.mk
