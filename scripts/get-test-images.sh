#!/bin/sh
#**********************************************************************
# Copyright (C) 2023 - The Geeqie Team
#
# Author: Colin Clark
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#**********************************************************************

## @file
## @brief Download test images
##
## $1 destination directory \n
## $2 git test image repo. \n
##

# GitHub workflow actions run on Ubuntu 22.04 (at the time of writing)
# Some libraries are not available in that version, so do not run
# image tests on the relevant files.
#
# 20.04 is checked for so that if a development system is running 23.x
# but all required libraries are not installed, an error will be flagged.
version=$(lsb_release -d)
if echo "$version" | grep -q "Ubuntu 22.04" > /dev/null
then
	exceptions="
	jxl
	libjxl-dev
	"
else
	exceptions=""
fi

if [ ! -d "$1" ]
then
	mkdir -p "$1"

	if ! git clone "$2" "$1"
	then
		exit 1
	fi
fi

for file in "$1/images/"*
do
	library_installed=true
	i=0

	for exception_string in $exceptions
	do
		if [ $((i % 2)) -eq 0 ]
		then
			file_extension="$exception_string"
		else
			library_file="$exception_string"
			basefile_name=$(basename "$file")
			basefile_match=$(basename "$basefile_name" "$file_extension")

			if [ ! "$basefile_name" = "$basefile_match" ]
			then
				if ! dpkg-query --show --showformat='${Status}' "$library_file" > /dev/null 2>&1
				then
					library_installed=false
					break
				fi
			fi
		fi

		i=$((i + 1))
	done

	if [ "$library_installed" = "true" ]
	then
		echo "$file"
	fi
done

exit 0
