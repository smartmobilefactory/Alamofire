#!/usr/bin/python
# Python import
import argparse
import subprocess

#
# Function Declaration
#

def ld_command(arch, isysroot, filelist, output):
	return [
		"libtool",
		"-static",
		"-arch_only", arch,
		"-syslibroot", isysroot,
		"-filelist", filelist,
		"-o", output,
	]


def static_link_parser():
	parser = argparse.ArgumentParser()
	parser.add_argument("-arch", required=True)
	parser.add_argument("-isysroot", required=True)
	parser.add_argument("-filelist", required=True)
	parser.add_argument("-o", dest="output", required=True)
	return parser

#
# Script Logic
#

if __name__ == "__main__":
	arguments, _ = static_link_parser().parse_known_args()
	command = ld_command(arguments.arch, arguments.isysroot, arguments.filelist, arguments.output)
	print(" ".join(command))
	print(subprocess.check_output(command))
