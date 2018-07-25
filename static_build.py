#!/usr/bin/python
# Python import
import argparse
import os
import subprocess

#
# Static Configuration
#


#
# Function Declaration
#

def static_build_parser():
	parser = argparse.ArgumentParser(description='Build and release a static framework')
	parser.add_argument('--path', help="Path to the root of the related repository.", required=True, default=None)
	parser.add_argument('--product', help="Github product name. Example: 'Alamofire/Alamofire'.", required=True, default=None)
	parser.add_argument('--version', help="Product's version.", required=True, default=None)
	return parser

def create_cartfile(root, product_name, product_version):
	# Remove existing Cartfile.resolved
	subprocess.call(['rm', '-rf', 'Cartfile.resolved'])
	subprocess.call(['rm', '-rf', 'Cartfile'])
	# Create new empty Cartfile
	subprocess.call(['touch', 'Cartfile'])
	# Write dependency inside the Cartfile
	dependency = ('github "%s" == %s' % (product_name, product_version))
	cartfile = open('Cartfile','w')
	cartfile.write(dependency)
	cartfile.close()

def carthage_update():
	# Execute carthage update to locally build the dynamic framework.
	subprocess.call(['carthage', 'update'])
	# Staticly link the binaries.
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


#
# Script Logic
#

if __name__ == "__main__":

	args, _ = static_build_parser().parse_known_args()
	# args = vars(parser.parse_args())
	root_path = args.path #['path']
	product_name = args.product # ['product']
	product_version = args.version #[ 'version']

	# TODO: check if Carthage is installed.
	# TODO: redirect script to root path when executing from outside folder.

	create_cartfile(root_path, product_name, product_version)

	carthage_update()

	retain_binaries()

	remove_carthage_from_repository()

	# commit_changes/release new binaries
