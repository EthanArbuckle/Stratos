ARCHS = armv7 arm64
TARGET = iphone:clang:latest:7.0

THEOS_BUILD_DIR = Packages

TWEAK_NAME = nighthawke
nighthawke_CFLAGS = -fobjc-arc
nighthawke_FILES = $(wildcard *.xm) $(wildcard *.mm)
nighthawke_FRAMEWORKS = UIKit QuartzCore CoreGraphics

SUBPROJECTS += Prefs

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	find $(FW_STAGING_DIR) -iname '*.plist' -or -iname '*.strings' -exec plutil -convert binary1 {} \;
	find $(FW_STAGING_DIR) -iname '*.png' -exec pincrush-osx -i {} \;
	find $(FW_STAGING_DIR) -name '.DS_Store' -exec rm {} \;

after-install::
	install.exec "killall -HUP SpringBoard"
