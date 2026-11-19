# The binary is built into build/, away from Info.plist. With Info.plist beside
# it, codesign treats the folder as a bundle and seals the source files too, so
# editing any of them would break the signature.
BINARY := build/calendar-export
ARCH := $(shell uname -m)
# Ad-hoc signing by default. Pass a real identity (e.g. "Apple Development: ...")
# to keep the Calendars permission across rebuilds.
SIGN_IDENTITY ?= -

$(BINARY) : main.swift Info.plist
	mkdir -p build
	swiftc -O -target $(ARCH)-apple-macos14.0 \
		-Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker Info.plist \
		-o $@ main.swift
	codesign --force --sign "$(SIGN_IDENTITY)" --identifier com.lmullen.calendar-export $@

clean :
	rm -rf build

.PHONY : clean
