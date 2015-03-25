# flymakeによるリアルタイム構文チェックのためのMakefile

# ここをプロジェクトごとに変更
PROJECT_NAME=AEDMap

PWD = $(shell pwd)
PROJECT_DIR    =\
 $(shell if [ -d ../$(PROJECT_NAME).xcodeproj ] ; then\
   echo $(PWD)/..;\
 elif [ -d ../../$(PROJECT_NAME).xcodeproj ] ; then\
   echo $(PWD)/../..;\
 elif [ -d ../../../$(PROJECT_NAME).xcodeproj ] ; then\
   echo $(PWD)/../../..;\
 else\
   echo '';\
 fi)


CLANG	    = /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
ARCH	    = -arch armv7
SDKPATH	    = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS8.1.sdk
SDK	    = -isysroot $(SDKPATH)
OS_VER_MIN  = -miphoneos-version-min=7.0
OPTIONS     = -fsyntax-only -x objective-c -std=gnu99\
 -x objective-c\
 -arch armv7\
 -fno-color-diagnostics\
 -fno-caret-diagnostics\
 -fno-show-column\
 -fsyntax-only\
 -fobjc-arc\
 -fmessage-length=0\
 -pipe\
 -std=c99\
 -Wno-trigraphs\
 -Wdeprecated-declarations\
 -fpascal-strings\
 -O0\
 -Wreturn-type\
 -Wunused-variable\
 -fexceptions\
 -fasm-blocks\
 -gdwarf-2\
 -fvisibility=hidden\
 -fobjc-abi-version=2\
 -fobjc-legacy-dispatch\
 -D__IPHONE_OS_VERSION_MIN_REQUIRED=40000\
 -DDEBUG
WARNINGS    = -Wreturn-type -Wparentheses -Wswitch -Wno-unused-parameter -Wunused-variable -Wunused-value
INCLUDES    = \
 -isystem "$(PROJECT_DIR)/Pods/Headers/Public/AFNetworking"\
 -I$(SDKPATH)/usr/include\
 -I.\
 -I"$(PROJECT_DIR)/$(PROJECT_NAME)/View"\
 -I"$(PROJECT_DIR)/$(PROJECT_NAME)/ViewController"\
 -I"$(PROJECT_DIR)/$(PROJECT_NAME)/ViewController/HomeView"\
 -I"$(PROJECT_DIR)/$(PROJECT_NAME)/ViewController/Member"\
 -I"$(PROJECT_DIR)/$(PROJECT_NAME)/ViewController/MemberList"\
 -I"$(PROJECT_DIR)/$(PROJECT_NAME)/ViewController/TimeLine"\
 -I"$(PROJECT_DIR)/$(PROJECT_NAME)/ViewController/Staff"\
 -I"$(PROJECT_DIR)/$(PROJECT_NAME)/Util"\
 -I"$(PROJECT_DIR)/Pods/SDWebImage"\
 -I"$(PROJECT_DIR)/Pods/Headers/Public"\
 -I"$(PROJECT_DIR)/Pods/Headers/Build"\
 -I"$(PROJECT_DIR)/Pods/Headers/Public/BlocksKit"\
 -I"$(PROJECT_DIR)/Pods/Headers/Public/AFNetworking"\
 -I"$(PROJECT_DIR)/Pods/SVProgressHUD"\
 -I"$(PROJECT_DIR)/Pods/GVUserDefaults/GVUserDefaults"\
 -I"$(PROJECT_DIR)/$(PROJECT_NAME)"\
 -include "$(PROJECT_DIR)/$(PROJECT_NAME)/$(PROJECT_NAME)-PrefixHeader.pch"

FRAMEWORKS  = -F../

check-syntax:
	$(CLANG) $(OPTIONS) $(ARCH) $(WARNINGS) $(SDK) $(OS_VER_MIN) $(INCLUDES) $(FRAMEWORKS) ${CHK_SOURCES}
