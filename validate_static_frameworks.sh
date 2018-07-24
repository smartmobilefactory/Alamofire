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

function valid_ios() {
	local VALID=1
	local BUILD_DIR="${IOS_BUILD_DIR}"
	local LIB_BIN="${BUILD_DIR}/${FRAMEWORK_BIN}"

	echo "Validating ${FRAMEWORK} at path: ${IOS_BUILD_DIR}"

	if [ -r "${LIB_BIN}" ]; then
		# Check expected architectures
		local REZ=$($LIPO_B -info "${LIB_BIN}")
		if [ "$REZ" != "Architectures in the fat file: ${LIB_BIN} are: i386 x86_64 armv7 armv7s arm64 " ]; then
			echo "ERROR: Unexpected result from $LIPO_B: \"${REZ}\""
			VALID=0
		else
			echo " GOOD: ${REZ}"
		fi

		# Check for bitcode where expected
		local ARCHS=("arm64" "armv7" "armv7s")
		for ARCH in ${ARCHS[*]}
		do
			local REZ=$($OTOOL_B -arch ${ARCH} -l "${LIB_BIN}" | $GREP_B LLVM)
			if [ "$REZ" == "" ]; then
				echo "ERROR: Did not find bitcode slice for ${ARCH}"
				VALID=0
			else
				echo " GOOD: Found bitcode slice for ${ARCH}"
			fi
		done

		# Check for bitcode where not expected
		local ARCHS=("i386")
		for ARCH in ${ARCHS[*]}
		do
			local REZ=$($OTOOL_B -arch ${ARCH} -l "${LIB_BIN}" | $GREP_B LLVM)
			if [ "$REZ" != "" ]; then
				echo "ERROR: Found bitcode slice for ${ARCH}"
				VALID=0
			else
				echo " GOOD: Did not find bitcode slice for ${ARCH}"
			fi
		done

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

	else
		echo "ERROR: \"${LIB_BIN}\" not found. Please be sure it has been built (see README.md)"
		VALID=0
	fi

	if [ $VALID -ne 1 ]; then
		fail "Invalid framework"
	fi
}

function validate() {
	local VALID=1
	local BUILD_DIR=$1
	local ARCH=$2
	local LIB_BIN="${BUILD_DIR}/${FRAMEWORK_BIN}"

	echo "Validating ${FRAMEWORK} at path: ${BUILD_DIR}"

	if [ -r "${LIB_BIN}" ]; then
		# Check expected architectures
		local REZ=$($LIPO_B -info "${LIB_BIN}" | $GREP_B "is architecture")
		if [ "$REZ" != "Non-fat file: ${LIB_BIN} is architecture: ${ARCH}" ]; then
			echo "ERROR: Unexpected result from $LIPO_B: \"${REZ}\""
			VALID=0
		else
			echo " GOOD: ${REZ}"
		fi

		local FILEINFO=$($FILE_B -L "${LIB_BIN}")
		if [ "$FILEINFO" != "${LIB_BIN}: current ar archive" ]; then
			echo "ERROR: Unexpected result from $FILE_B: \"${FILEINFO}\""
			VALID=0
		else
			echo " GOOD: ${FILEINFO}"
		fi

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

		local REZ=$($OTOOL_B -arch ${ARCH} -l "${LIB_BIN}" | $GREP_B LLVM)
			if [ "$REZ" != "" ]; then
				echo "ERROR: Found bitcode slice for ${ARCH}"
				VALID=0
			else
				echo " GOOD: Did not find bitcode slice for ${ARCH}"
			fi

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
		valid_ios
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
