#!/bin/sh

#  build-framework-ios.sh
#  OpenSSL-iOS
#
#  Created by Josip Cavar on 15/07/16.
#  Modified by @levigroker and @kevindelord.
#  Copyright © 2018 Smart Mobile Factory. All rights reserved.

set -e
set +u

### Configuration

# Fully qualified binaries (_B suffix to prevent collisions)
CP_B="/bin/cp"
MKDIR_B="/bin/mkdir"

# Constants
UNIVERSAL_OUTPUTFOLDER=${SRCROOT}/Frameworks/Static/iOS
IPHONE_SIMULATOR_BUILD_DIR=${BUILD_DIR}/${CONFIGURATION}-iphonesimulator
IPHONE_DEVICE_BUILD_DIR=${BUILD_DIR}/${CONFIGURATION}-iphoneos

DEBUG=${DEBUG:-0}
export DEBUG
[ $DEBUG -ne 0 ] && set -x

### Function Declaration

function copy_swiftmodule_paths() {
	DESTINATION=$1
	SOURCE=$2
	ARCH=$3

	SWIFT_MODULES_DIR="${SOURCE}/${ARCH}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/."
	if [ -d "${SWIFT_MODULES_DIR}" ]; then
		echo "  GOOD: Found swiftmodule for architecture ${ARCH} at: ${SWIFT_MODULES_DIR}"
		cp $SWIFT_MODULES_DIR/* $DESTINATION
	else
		echo "WARNING: No swiftmodule found for architecture: ${ARCH}"
	fi
}

function copy_modulemap_paths() {
	DESTINATION=$1
	SOURCE=$2
	ARCH=$3

	SWIFT_MODULEMAP="${SOURCE}/${ARCH}/${PROJECT_NAME}.framework/Modules/module.modulemap"
	if [ -f "${SWIFT_MODULEMAP}" ]; then
		echo "  GOOD: Found modulemap for architecture ${ARCH} at: ${SWIFT_MODULEMAP}"
		cp $SWIFT_MODULEMAP $DESTINATION
	else
		echo "WARNING: No modulemap found for architecture: ${ARCH}"
	fi
}

function copy_swiftmodule() {

	# Create clean destination folder
	DESTINATION="${UNIVERSAL_OUTPUTFOLDER}/${PRODUCT_NAME}.framework/Modules/${PRODUCT_NAME}.swiftmodule"
	echo "CREATING: ${DESTINATION} ..."
	$MKDIR_B -p "${DESTINATION}"

	copy_swiftmodule_paths $DESTINATION $IPHONE_DEVICE_BUILD_DIR "arm64"
	copy_swiftmodule_paths $DESTINATION $IPHONE_DEVICE_BUILD_DIR "armv7"
	copy_swiftmodule_paths $DESTINATION $IPHONE_DEVICE_BUILD_DIR "armv7s"

	copy_swiftmodule_paths $DESTINATION $IPHONE_SIMULATOR_BUILD_DIR "x86_64"
	copy_swiftmodule_paths $DESTINATION $IPHONE_SIMULATOR_BUILD_DIR "i386"
}

function copy_modulemap() {

	# Create clean destination folder
	DESTINATION="${UNIVERSAL_OUTPUTFOLDER}/${PRODUCT_NAME}.framework/Modules"
	echo "CREATING: ${DESTINATION} ..."
	$MKDIR_B -p "${DESTINATION}"

	copy_modulemap_paths $DESTINATION $IPHONE_DEVICE_BUILD_DIR "arm64"
	copy_modulemap_paths $DESTINATION $IPHONE_DEVICE_BUILD_DIR "armv7"
	copy_modulemap_paths $DESTINATION $IPHONE_DEVICE_BUILD_DIR "armv7s"

	copy_modulemap_paths $DESTINATION $IPHONE_SIMULATOR_BUILD_DIR "x86_64"
	copy_modulemap_paths $DESTINATION $IPHONE_SIMULATOR_BUILD_DIR "i386"
}
### Script Logic

# Copy the swiftmodule and swiftdoc for all available architectures.
copy_swiftmodule

# Copy the generated module.modulemap files.
copy_modulemap
