#!/bin/bash

export REL_VER=$1

function usage {
	echo Please supply a release version number i.e. 0.2.1 [Major.Minor.Patch]
	echo "   MAJOR version when you make incompatible API changes,"
	echo "   MINOR version when you add functionality in a backwards-compatible manner, and"
	echo "   PATCH version when you make backwards-compatible bug fixes."
	vers.sh
	exit 1
}

if [ "${REL_VER:-}" == "" ]; then
	usage
fi
if [ -e "$REL_VER" ]; then
	usage
fi

# Update the version numbers in some files
# README.md: (version: 0.3.3)
perl -i.bak -pne 's{(version.*?[=:].*?)([0-9]+\.[0-9]+\.[0-9]+)}{$1$ENV{REL_VER}}xmsg;' \
   $VERFILES

function check_version {
	local file
	file="$1"
	if egrep "version.*[:=]" "$file" | grep "$REL_VER" ; then
		echo ok "$file" version updated
	else
		echo NOT OK - "$file" does not contain $REL_VER release version
		exit 40
	fi
}

check_version README.md
check_version mocha.js
check_version mocha.css
