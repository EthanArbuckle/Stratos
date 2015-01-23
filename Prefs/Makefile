DEBUG = 1
GO_EASY_ON_ME = 1
ARCHS = armv7 arm64
TARGET = iphone:clang:latest:7.0

BUNDLE_NAME = StratosPrefs
StratosPrefs_CFLAGS = -fobjc-arc
StratosPrefs_FILES = $(wildcard *.mm)
StratosPrefs_INSTALL_PATH = /Library/PreferenceBundles
StratosPrefs_FRAMEWORKS = UIKit CoreGraphics Social AVFoundation
StratosPrefs_PRIVATE_FRAMEWORKS = Preferences
StratosPrefs_LIBRARIES = MobileGestalt

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/StratosPrefs.plist$(ECHO_END)
	cp -r Translations/* $(THEOS_STAGING_DIR)/Library/PreferenceBundles/StratosPrefs.bundle/
