ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = M7MD

M7MD_FRAMEWORKS = IOKit UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController

# --- Include yolları (SDK/SHANKS_PUBGM_Basic.hpp üçün) ---
M7MD_INCLUDE = -I. -ISDK -ISDK/SDK

M7MD_CCFLAGS = -w -std=gnu++14 -fno-rtti -fno-exceptions -DNDEBUG $(M7MD_INCLUDE)
M7MD_CFLAGS  = -w -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value $(M7MD_INCLUDE)

# .mm faylları (Objective-C++) üçün ayrıca — BU SƏTİR ƏLAVƏ OLUNDU
M7MD_OBJCFLAGS   = -w -fobjc-arc -Wno-deprecated-declarations $(M7MD_INCLUDE)
M7MD_OBJCXXFLAGS = -w -fobjc-arc -Wno-deprecated-declarations -std=gnu++14 $(M7MD_INCLUDE)

M7MD_FILES = Tweak.mm Menu.mm View/OverlayView.mm imgui_impl_metal.mm $(wildcard imgui/*.cpp)

include $(THEOS_MAKE_PATH)/tweak.mk
M7MD_CFLAGS += -I$(THEOS_PROJECT_DIR)/SDK
