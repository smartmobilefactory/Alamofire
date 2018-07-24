#!/bin/bash

# Validate OpenSSL binaries for macOS and iOS.
#
# Created by Kevin Delord
# June 13, 2018
##

# -u  Attempt to use undefined variable outputs error message, and forces an exit
set -u

### Configuration

FRAMEWORK="Alamofire.framework"
FRAMEWORK_BIN="${FRAMEWORK}/Alamofire"

# Build Directories configuration
MAC_BUILD_DIR="Frameworks/Static/Mac"
IOS_BUILD_DIR="Frameworks/Static/iOS"
WATCHOS_BUILD_DIR="Frameworks/Static/watchOS"
TVOS_BUILD_DIR="Frameworks/Static/tvOS"

# Fully qualified binaries (_B suffix to prevent collisions)
GREP_B="/usr/bin/grep"
LIPO_B="/usr/bin/lipo"
OTOOL_B="/usr/bin/otool"
FILE_B="/usr/bin/file"

### Function Declaration

function fail() {
    echo "Failed: $@" >&2
    exit 1
}

function usage() {
	echo "Usage: $0 [macOS | iOS | tvOS | watchOS]" >&2
	echo "" >&2
	echo "    Example: $0 macOS" >&2
	echo "" >&2
    exit 1
}

function validate_bitcode() {
	ARCH=$1
	LIB_BIN=$2

	local REZ=$($OTOOL_B -arch ${ARCH} -l "${LIB_BIN}" | $GREP_B -i LLVM)
	if [ "$REZ" == "" ]; then
		echo "ERROR: Did not find bitcode slice for ${ARCH}"
		VALID=0
	else
		echo " GOOD: Found bitcode slice for ${ARCH}"
	fi

	return "$VALID"
}

function validate_modulemap() {
	BUILD_DIR=$1

	local EXPECTING=("${BUILD_DIR}/${FRAMEWORK}/Modules/module.modulemap")
	for EXPECT in ${EXPECTING[*]}
	do
		if [ -f "${EXPECT}" ]; then
			echo " GOOD: Found expected file: \"${EXPECT}\""
		else
			echo "ERROR: Did not file expected file: \"${EXPECT}\""
			VALID=0
		fi
	done

	return "$VALID"
}

function validate_static_framework() {
	LIB_BIN=$1

	local FILEINFO=$($FILE_B -L "${LIB_BIN}" | $GREP_B -i "current ar archive")
	if [ "$FILEINFO" == "" ]; then
		echo "ERROR: Unexpected result from $FILE_B: \"${FILEINFO}\""
		VALID=0
	else
		echo " GOOD: ${FILEINFO}"
	fi

	return "$VALID"
}

function validate_architecture() {
	LIB_BIN=$1
	ARCH=$2

	local REZ=$($LIPO_B -info "${LIB_BIN}" | $GREP_B -i "architecture")
	if [ "$REZ" == "" ]; then
		echo "ERROR: Unexpected architecture for: \"${REZ}\""
		VALID=0
	else
		REZ=$($LIPO_B -info "${LIB_BIN}" | $GREP_B -i "${ARCH}")
		if [ "$REZ" == "" ]; then
			echo "ERROR: Unexpected result from $LIPO_B: \"${REZ}\""
			VALID=0
		else
			echo " GOOD: ${REZ}"
		fi
	fi

	return "$VALID"
}

function validate() {
	local VALID=1
	local BUILD_DIR=$1
	local ARCH=$2
	local LIB_BIN="${BUILD_DIR}/${FRAMEWORK_BIN}"

	echo "Validating ${FRAMEWORK} at path: ${BUILD_DIR}"

	if [ -r "${LIB_BIN}" ]; then

		validate_architecture $LIB_BIN $ARCH
		VALID=$?

		validate_static_framework $LIB_BIN
		VALID=$?

		validate_modulemap $BUILD_DIR
		VALID=$?

		validate_bitcode $ARCH $LIB_BIN
		VALID=$?

	else
		echo "ERROR: \"${LIB_BIN}\" not found. Please be sure it has been built (see README.md)"
		VALID=0
	fi

	if [ $VALID -ne 1 ]; then
		fail "Invalid framework"
	fi
}

### Script Logic

if [[ $# -eq 0 ]]; then
	usage
fi

for i in "$@"
do
case $i in
	iOS)
		validate "${IOS_BUILD_DIR}" "arm64"
		validate "${IOS_BUILD_DIR}" "x86_64"
		validate "${IOS_BUILD_DIR}" "armv7"
		validate "${IOS_BUILD_DIR}" "armv7s"
		validate "${IOS_BUILD_DIR}" "i386"
	;;
	macOS)
		validate "${MAC_BUILD_DIR}" "x86_64"
	;;
	tvOS)
		validate "${TVOS_BUILD_DIR}" "arm64"
	;;
	watchOS)
		validate "${WATCHOS_BUILD_DIR}" "armv7k"
	;;
	*)
		echo "Invalid parameter: ${i}" >&2
		echo "" >&2
		usage
	;;
esac
done
