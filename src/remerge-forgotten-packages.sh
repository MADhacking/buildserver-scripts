#! /bin/bash

function helpscreen
{
	echo "Usage: remerge-fogotten-packages [OPTION]..."
	echo "Reinstalls any packages which are installed but which do not have a"
	echo "corresponding binary package available"
	echo
	echo "  -b, --include-bdeps            include build-time dependencies when searching"
	echo "                                 for packages"
	echo "  -p, --pretend                  do not perform any actions but instead list the"
	echo "                                 packages which would have their binary packages"
	echo "                                 rebuilt"
}

DEPS="--with-bdeps n"

# Process command line switches
while [ $# -gt 0 ]
do
	case $1 in
	    -b|--include-bdeps)
			DEPS="--with-bdeps y"
			shift 1
	    ;;
	    -p|--pretend)
			PRETEND=1
			shift 1
	    ;;
				
		*)
			helpscreen
			shift 1
			exit
		;;
	esac
done

# Source the profile
source /etc/profile &>/dev/null

# Check to make sure we are being run from inside the buildspace.
if [ -z "$BUILDSPACE_NAME" ]; then
	echo "ERROR: $0 should only be run from inside a buildspace!" >&2
	exit 1
fi

# Remerge forgotten binaries!
emerge -pvek world ${DEPS} 2>&1 1>&1 | \
	awk -F "] " '/\[ebuild.+\]/ { print $2 }' | \
		awk '{print "=" $1}' | xargs | xargs -r -t emerge -1pv

[[ $? -eq 0 && -z ${PRETEND} ]] && emerge -pvek world ${DEPS} 2>&1 1>&1 | \
	awk -F "] " '/\[ebuild.+\]/ { print $2 }' | \
		awk '{print "=" $1}' | xargs | xargs -r emerge -1		