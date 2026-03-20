export THEOS = /Users/az/theos
export ARCHS = arm64 arm64e
export TARGET = iphone:clang:14.5:14.0
THEOS_PACKAGE_SCHEME = rootless
INSTALL_TARGET_PROCESSES = SpringBoard

TWEAK_NAME = ReynardDefault
ReynardDefault_FILES = Tweak.x
ReynardDefault_CFLAGS = -fobjc-arc
ReynardDefault_FRAMEWORKS = Foundation
ReynardDefault_EXTRA_FRAMEWORKS = FrontBoardServices

SUBPROJECTS = ReynardDefaultPrefs ReynardDefaultCC

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
