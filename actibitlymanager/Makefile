include theos/makefiles/common.mk

TWEAK_NAME = ActiBitlyManager
ActiBitlyManager_OBJC_FILES = ActiBitlyManager.m ../BitlyConnection.m ../BitlyPreferences.m ../UIViewController+Additions.m
ActiBitlyManager_FRAMEWORKS = Foundation UIKit CoreGraphics 
ActiBitlyManager_LDFLAGS = -lactivator

include $(THEOS_MAKE_PATH)/tweak.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p com.sharedroutine.actibitlymanager$(ECHO_END)
	$(ECHO_NOTHING)cp -r ./Resources/Info.plist ./com.sharedroutine.actibitlymanager/Info.plist$(ECHO_END)
	$(ECHO_NOTHING)mkdir -p ../_/Library/Activator/Listeners/com.sharedroutine.actibitlymanager/$(ECHO_END)
	$(ECHO_NOTHING)cp -r com.sharedroutine.actibitlymanager ../_/Library/Activator/Listeners/$(ECHO_END)

after-install::
	install.exec "killall -9 SpringBoard"
