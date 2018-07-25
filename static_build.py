#!/usr/bin/python
# Python import
import argparse
import os
import subprocess
import sys

#
# TODO
#

# TODO: check if Carthage is installed.
# TODO: redirect script to root path when executing from outside folder.
# TODO: custom help message
# TODO: commit_changes/release new binaries

#
# Function Declaration
#

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

def create_cartfile(root, product_name, product_version):
	path = 'Cartfile'
	dependency = ('github "%s" == %s' % (product_name, product_version))
	# Remove existing file
	subprocess.call(['rm', '-rf', path])
	# Create new empty file
	subprocess.call(['touch', path])
	# Write dependency inside the file
	cartfile = open(path,'w')
	cartfile.write(dependency)
	cartfile.close()

def carthage_update():
	# Execute carthage update to locally build the dynamic framework.
	# subprocess.call(['carthage', 'update'])
	# Statically link the binaries.
	subprocess.call(['./static_link.sh'])

def remove_carthage_from_repository():
	# Remove Cartfile file
	subprocess.call(['rm', '-rf', 'Cartfile'])
	# Remove Cartfile.resolved file
	subprocess.call(['rm', '-rf', 'Cartfile.resolved'])
	# Remove Cathage folder
	subprocess.call(['rm', '-rf', 'Carthage'])

def retain_binaries():
	# Remove any existing 'Releases' folder
	subprocess.call(['rm', '-rf', 'Releases'])
	# Retain buitl binaries
	subprocess.call(['mv', 'Carthage/Build', 'Releases'])

def link_binaries(arguments):
	libtool_command = [
		"libtool",
		"-static",
		"-arch_only", arguments.arch,
		"-syslibroot", arguments.isysroot,
		"-filelist", arguments.filelist,
		"-o", arguments.output
	]
	print(" ".join(libtool_command))
	print(subprocess.check_output(libtool_command))

def build_binaries(arguments):
	create_cartfile(arguments.path, arguments.product, arguments.version)
	carthage_update()
	retain_binaries()
	remove_carthage_from_repository()
#
# Script Logic
#

if __name__ == "__main__":

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
