ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = M7MD

M7MD_FRAMEWORKS = IOKit UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController

M7MD_CCFLAGS = -w -std=gnu++14 -fno-rtti -fno-exceptions -DNDEBUG
M7MD_CFLAGS = -w -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -I.

M7MD_FILES = Tweak.mm Menu.mm Helper/ini_rw.c imgui_impl_metal.mm $(wildcard imgui/*.cpp) $(wildcard imgui/*.mm)

include $(THEOS_MAKE_PATH)/tweak.mk
