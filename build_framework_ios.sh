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

# Avoid recursively calling this script.
if [[ $SF_MASTER_SCRIPT_RUNNING ]] ; then
	exit 0
fi
set -u
export SF_MASTER_SCRIPT_RUNNING=1

# Fully qualified binaries (_B suffix to prevent collisions)
RM_B="/bin/rm"
CP_B="/bin/cp"
MKDIR_B="/bin/mkdir"
LIPO_B="/usr/bin/lipo"

# Constants
UNIVERSAL_OUTPUTFOLDER=${SRCROOT}/Frameworks/Static/iOS
IPHONE_SIMULATOR_BUILD_DIR=${BUILD_DIR}/${CONFIGURATION}-iphonesimulator
IPHONE_DEVICE_BUILD_DIR=${BUILD_DIR}/${CONFIGURATION}-iphoneos

DEBUG=${DEBUG:-0}
export DEBUG
[ $DEBUG -ne 0 ] && set -x

### Function Declaration

function check_valid_target() {
	# Take build target
	if [[ "$SDK_NAME" =~ ([A-Za-z]+) ]] ; then
		SF_SDK_PLATFORM=${BASH_REMATCH[1]}
	else
		echo "Could not find platform name from SDK_NAME: $SDK_NAME"
		exit 1
	fi

	if [[ "$SF_SDK_PLATFORM" != "iphoneos" ]] ; then
		echo "Wrong target. Must select 'Generic iOS Device' as the build target."
		exit 1
	fi
}

function build() {
	SDK=$1
	ARCH=$2

	echo "BUILDING ARCH: ${ARCH}"

	xcodebuild  -project "${PROJECT_FILE_PATH}" \
				-target "${TARGET_NAME}" \
				-configuration "${CONFIGURATION}" \
				-sdk $SDK \
				BUILD_DIR="${BUILD_DIR}" \
				OBJROOT="${OBJROOT}" \
				BUILD_ROOT="${BUILD_ROOT}" \
				CONFIGURATION_BUILD_DIR="${BUILD_DIR}/${CONFIGURATION}-${SDK}/${ARCH}/" \
				SYMROOT="${SYMROOT}" \
				ENABLE_BITCODE=YES BITCODE_GENERATION_MODE=bitcode \
				ARCHS="${ARCH}" \
				VALID_ARCHS="${ARCH}" \
				$ACTION
}

function build_all_architectures() {
	# Build simulator architectures.
	build iphonesimulator "i386"
	build iphonesimulator "x86_64"

	# Build device architectures.
	build iphoneos "arm64"
	build iphoneos "armv7"
	build iphoneos "armv7s"
}

function create_universal_file() {
	# Because `lipo` does not create the output file,
	# We need to copy the framework structure into the universal folder.
	# The last build contains the complete structure (here 'armv7s').
	$CP_B -R "${IPHONE_DEVICE_BUILD_DIR}/armv7s/${PRODUCT_NAME}.framework" "${UNIVERSAL_OUTPUTFOLDER}/${PRODUCT_NAME}.framework"

	echo "Create an universal file to combine all architectures."

	# Simulator Build
	BUILD_I386="${IPHONE_SIMULATOR_BUILD_DIR}/i386/${PRODUCT_NAME}.framework/${PRODUCT_NAME}"
	BUILD_X86_64="${IPHONE_SIMULATOR_BUILD_DIR}/x86_64/${PRODUCT_NAME}.framework/${PRODUCT_NAME}"
	# Device Build
	BUILD_ARM64="${IPHONE_DEVICE_BUILD_DIR}/arm64/${PRODUCT_NAME}.framework/${PRODUCT_NAME}"
	BUILD_ARMV7="${IPHONE_DEVICE_BUILD_DIR}/armv7/${PRODUCT_NAME}.framework/${PRODUCT_NAME}"
	BUILD_ARMV7S="${IPHONE_DEVICE_BUILD_DIR}/armv7s/${PRODUCT_NAME}.framework/${PRODUCT_NAME}"

	UNIVERSAL_BUILD="${UNIVERSAL_OUTPUTFOLDER}/${PRODUCT_NAME}.framework/${PRODUCT_NAME}"

	$LIPO_B -create $BUILD_I386 $BUILD_X86_64 $BUILD_ARM64 $BUILD_ARMV7 $BUILD_ARMV7S -output $UNIVERSAL_BUILD
}

function prepare_build() {
	# Remove all existing build.
	$RM_B -rf $UNIVERSAL_OUTPUTFOLDER
	$RM_B -rf $IPHONE_SIMULATOR_BUILD_DIR
	$RM_B -rf $IPHONE_DEVICE_BUILD_DIR

	# Create an empty universal framework structure.
	$MKDIR_B -p "${UNIVERSAL_OUTPUTFOLDER}"
}

function validate_frameworks() {
	./validate_static_frameworks.sh iOS
}

### Script Logic

# Validate 'Generic iOS Device' target.
check_valid_target

# Recreate destination folder.
prepare_build

# Build archs: i386 x86_6 arm64 armv7 armv7s
build_all_architectures

# Combine all architectures.
create_universal_file

#
# After Success Scripts
#
# Because the xcodebuild is done in this script and not in xcode,
# the after success script must be executed here.
# Otherwise they will be called before the actual end of the build process.
#

# Validate Frameworks.
validate_frameworks
