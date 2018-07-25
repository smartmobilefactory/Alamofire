#!/usr/bin/python
# Python import
import argparse
import os
import subprocess
import sys

#
# Function Declaration
#

# Common

def check_required_dependencies():
	required_dependencies = ['carthage', 'mktemp', 'trap', 'rm', 'export', 'mv', 'libtool', 'touch']
	for dependency in required_dependencies:
		try:
			subprocess.check_output(['command', '-v', dependency])
		except subprocess.CalledProcessError as error:
			print("Error: '%s' not found" % dependency)
			exit(1)

def parser():
	parser = argparse.ArgumentParser(description='Build and release a static framework')
	subparsers = parser.add_subparsers(help='Available commands')

	# Static Build: Automatically executed by xcodebuild
	link_parser = subparsers.add_parser('link', help='Statically link binaries. Used by xcodebuild.')
	link_parser.add_argument("-arch", required=True, default=None)
	link_parser.add_argument("-isysroot", required=True, default=None)
	link_parser.add_argument("-filelist", required=True, default=None)
	link_parser.add_argument("-o", dest="output", required=True)

	# Dynamic Build: Manually executed.
	build_parser = subparsers.add_parser('build', help='Build Static Framework')
	build_parser.add_argument('--path', help="Path to the root of the related repository.", required=True, default=None)
	build_parser.add_argument('--product', help="Github product name. Example: 'Alamofire/Alamofire'.", required=True, default=None)
	build_parser.add_argument('--version', help="Product's version.", required=True, default=None)

	return parser

# Build

def create_cartfile(root, product_name, product_version):
	path = root + '/Cartfile'
	dependency = ('github "%s" == %s' % (product_name, product_version))
	# Remove existing file
	subprocess.call(['rm', '-rf', path])
	# Create new empty file
	subprocess.call(['touch', path])
	# Write dependency inside the file
	cartfile = open(path,'w')
	cartfile.write(dependency)
	cartfile.close()

def carthage_update(root):
	# Create a temporary xcconfig file.
	xcconfig = subprocess.check_output(['mktemp', '/tmp/static.xcconfig.XXXXXX']).strip()
	# Setup custom xcode build configurations.
	file = open(xcconfig,'w')
	file.write("LD = %s\n" % os.path.realpath(__file__))
	file.write("DEBUG_INFORMATION_FORMAT = dwarf\n")
	file.close()

	# Redirect the script execution to the root of the folder (where the Cartfile is).
	cd = ('cd %s' % root)
	# Remove temporary file after process.
	trap = ("trap 'rm -f \"%s\"' INT TERM HUP EXIT" % xcconfig)
	# Export/Overwrite the default xcode config file.
	export = ('export XCODE_XCCONFIG_FILE="%s"' % xcconfig)
	# Finally build the binaries statically using Carthage
	build = 'carthage update'

	# Use os.system to run all commands inside the same environment.
	command_line = " ; ".join([cd, trap, export, build])
	os.system(command_line)

def remove_carthage_from_repository(root):
	# Remove Cartfile file
	subprocess.call(['rm', '-rf', root + '/Cartfile'])
	# Remove Cartfile.resolved file
	subprocess.call(['rm', '-rf', root + '/Cartfile.resolved'])
	# Remove Cathage folder
	subprocess.call(['rm', '-rf', root + '/Carthage'])

def retain_binaries(root):
	# Remove any existing 'Releases' folder
	subprocess.call(['rm', '-rf', root + '/Releases'])
	# Retain buitl binaries
	subprocess.call(['mv', root + '/Carthage/Build', root + '/Releases'])

def build_binaries(arguments):
	root = arguments.path
	create_cartfile(root, arguments.product, arguments.version)
	carthage_update(root)
	retain_binaries(root)
	remove_carthage_from_repository(root)

# Link

def link_binaries(arguments):
	libtool_command = [
		"libtool",
		"-static",
		"-arch_only", arguments.arch,
		"-syslibroot", arguments.isysroot,
		"-filelist", arguments.filelist,
		"-o", arguments.output
	]
	# Print command line and output as stdout is redirected onto a log file.
	print(" ".join(libtool_command))
	print(subprocess.check_output(libtool_command))

#
# Script Logic
#

if __name__ == "__main__":

	check_required_dependencies()

	if 'build' not in sys.argv and '-h' not in sys.argv and '--help' not in sys.argv:
		# Xcodebuild does not use the custom 'link' command.
		# If neither 'build' or 'help' is in use, add the 'link' parameter to force the logic.
		sys.argv.insert(1, 'link')

	args, here = parser().parse_known_args()

	if hasattr(args, 'arch') and hasattr(args, 'isysroot') and hasattr(args, 'filelist') and hasattr(args, 'output'):
		link_binaries(args)

	elif hasattr(args, 'path') and hasattr(args, 'product') and hasattr(args, 'version'):
		build_binaries(args)
	else:
		print("Error Invalid Arguments.")
		exit(1)
