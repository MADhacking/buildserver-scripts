#! /bin/bash

function helpscreen
{
	echo "Usage: update-portage-metadata"
	echo "Rebuilds the portage metadata and, if installed, rebuilds the eix cache"
}

# If we have been run with parameters then display help and quit
[[ -n ${1} ]] && helpscreen && exit

# Source the profile
source /etc/profile &>/dev/null

# Check to make sure we are being run from inside the buildspace.
if [[ -z "$BUILDSPACE_NAME" ]]; then
	echo "ERROR: $0 should only be run from inside a buildspace!" >&2
	exit
fi

echo -n "Rebuilding metadata cache for $BUILDSPACE_NAME build-space..." 
emerge --metadata --quiet 1>/dev/null
(( ! $? )) && echo "done." || echo "failed."

# If eix is installed then update the cache
if [[ -x /usr/bin/eix-update ]]; then
	echo -n "Rebuilding eix cache for $BUILDSPACE_NAME build-space..."
	eix-update --quiet
	(( ! $? )) && echo "done." || echo "failed."
fi
