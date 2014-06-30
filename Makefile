export ARCHS = armv7 arm64
include theos/makefiles/common.mk

BUNDLE_NAME = BitlyManager
BitlyManager_FILES = BitlyManager.mm SSKeychain.m BitlyConnection.m UIViewController+Additions.m PSBitlyUserHistoryViewController.m
BitlyManager_INSTALL_PATH = /Library/PreferenceBundles
BitlyManager_FRAMEWORKS = UIKit Security CoreGraphics
BitlyManager_PRIVATE_FRAMEWORKS = Preferences
BitlyManager_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/BitlyManager.plist$(ECHO_END)
SUBPROJECTS += ambitlymanager
include $(THEOS_MAKE_PATH)/aggregate.mk
