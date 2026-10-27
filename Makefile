THEOS = $(shell echo ~/theos)
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = -

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PubgOverlay

PubgOverlay_FILES = Tweak.x MenuB.mm
PubgOverlay_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/tweak.mk
include $(THEOS)/makefiles/package.mk
