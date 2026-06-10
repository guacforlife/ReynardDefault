export ARCHS = arm64 arm64e
export TARGET = iphone:clang:14.5:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

.PHONY: rootless rootful both

rootless:
	@env -i HOME="$$HOME" PATH="$$PATH" THEOS="$$THEOS" THEOS_PACKAGE_SCHEME=rootless FINALPACKAGE=1 make -f Makefile clean package

rootful:
	@env -i HOME="$$HOME" PATH="$$PATH" THEOS="$$THEOS" FINALPACKAGE=1 make -f Makefile clean package

both: rootless rootful
	@echo "Built both variants in packages/"

TWEAK_NAME = ReynardDefault
ReynardDefault_FILES = Tweak.x
ReynardDefault_CFLAGS = -fobjc-arc
ReynardDefault_FRAMEWORKS = Foundation
ReynardDefault_EXTRA_FRAMEWORKS = FrontBoardServices

SUBPROJECTS = ReynardDefaultPrefs ReynardDefaultCC

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
