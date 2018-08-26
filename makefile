# What you WANT on DOS is:
# EDIT CONFIG.B, COPY CONFIG.B to CONFIG.BAT, RUN BUILD.BAT
# On Linux, use config.mak, and "make all", "make clean", or "make clobber"
# On Windows, use config.mak, and
# "mingw32-make all", "mingw32-make clean", or "mingw32-make clobber"

default: all

build:
	build

bin\kwc8616.sys:
	build -r wc 86 fat16

bin\kwc8632.sys:
	build -r wc 86 fat32

# use as follows: wmake -ms zip VERSION=2029
zip_src:
	cd ..\..
	zip -9 -r -k source/ke$(VERSION)s.zip source/ke$(VERSION) -i@source/ke$(VERSION)/filelist
	cd source\ke$(VERSION)

BINLIST1 = doc bin/kernel.sys bin/sys.com
# removed - as the 2nd zip -r line to add those to the zip:
# BINLIST2 = bin/config.sys bin/autoexec.bat bin/command.com bin/install.bat

zipfat16: bin\kwc8616.sys
	mkdir doc
	mkdir doc\kernel
	copy docs\*.txt doc\kernel
	copy docs\*.cvs doc\kernel
	copy docs\copying doc\kernel
	copy docs\*.lsm doc\kernel
	del doc\kernel\build.txt
	del doc\kernel\lfnapi.txt
	copy bin\kwc8616.sys bin\kernel.sys
	zip -r -k ../ke$(VERSION)16.zip $(BINLIST)
#	utils\rmfiles doc\kernel\*.txt doc\kernel\*.cvs doc\kernel\*.lsm doc\kernel\copying
	rmdir doc\kernel
	rmdir doc

zipfat32: bin\kwc8632.sys
	mkdir doc
	mkdir doc\kernel
	copy docs\*.txt doc\kernel
	copy docs\*.cvs doc\kernel
	copy docs\copying doc\kernel
	copy docs\*.lsm doc\kernel
	del doc\kernel\build.txt
	del doc\kernel\lfnapi.txt
	copy bin\kwc8632.sys bin\kernel.sys
	zip -r -k ../ke$(VERSION)32.zip $(BINLIST)
#	utils\rmfiles doc\kernel\*.txt doc\kernel\*.cvs doc\kernel\*.lsm doc\kernel\copying
	rmdir doc\kernel
	rmdir doc

zip: zip_src zipfat16 zipfat32

#Linux part
#defaults: override using config.mak
export

ifeq ($(OS),Windows_NT)
BUILDENV ?= windows
else
BUILDENV ?= linux
endif

ifeq ($(BUILDENV),windows)
COMPILER=owwin
TEST_F=type >nul 2>nul
else
COMPILER=gcc
TEST_F=test -f
ifndef WATCOM
  WATCOM=$(HOME)/watcom
  PATH:=$(WATCOM)/binl:$(PATH)
endif
endif

XCPU=386
XFAT=32
XUPX=
XNASM=nasm
#MAKE=make
XLINK=ld
#ALLCFLAGS=-DDEBUG

-include config.mak
srcdir ?= $(CURDIR)
ifdef XUPX
  UPXOPT=-U
endif

define mdir
	if [ ! -f $(1)/makefile ]; then \
	    mkdir $(1) 2>/dev/null ; \
	    ln -s $(srcdir)/$(1)/makefile $(1)/makefile ; \
	fi
	cd $(1) && $(MAKE) srcdir=$(srcdir)/$(1) $(2)
endef

all:
	+$(call mdir,utils,production)
	+$(call mdir,lib,production)
	+$(call mdir,drivers,production)
#	cd boot && $(MAKE) production
#	cd sys && $(MAKE) production
	+$(call mdir,fdpp,all)

clean:
	+$(call mdir,utils,clean)
	+$(call mdir,lib,clean)
	+$(call mdir,drivers,clean)
#	cd boot && $(MAKE) clean
#	cd sys && $(MAKE) clean
	+$(call mdir,fdpp,clean)

clobber:
	+$(call mdir,utils,clobber)
	+$(call mdir,lib,clobber)
	+$(call mdir,drivers,clobber)
#	cd boot && $(MAKE) clobber
#	cd sys && $(MAKE) clobber
	+$(call mdir,fdpp,clobber)

install:
	cd fdpp && $(MAKE) srcdir=$(srcdir)/fdpp install
