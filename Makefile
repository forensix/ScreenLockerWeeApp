include theos/makefiles/common.mk

LIBRARY_NAME = ScreenLockerWeeApp

ScreenLockerWeeApp_FILES = ScreenLockerWeeApp.mm

ScreenLockerWeeApp_INSTALL_PATH = /System/Library/WeeAppPlugins/ScreenLockerWeeApp.bundle

ScreenLockerWeeApp_FRAMEWORKS = UIKit Foundation
ScreenLockerWeeApp_PRIVATE_FRAMEWORKS = BulletinBoard

include $(THEOS_MAKE_PATH)/library.mk
