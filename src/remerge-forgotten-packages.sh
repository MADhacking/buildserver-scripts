#! /bin/bash

# Source the profile
source /etc/profile &>/dev/null

# Check to make sure we are being run from inside the buildspace.
if [ -z "$BUILDSPACE_NAME" ]; then
  echo "ERROR: $0 should only be run from inside a buildspace!" >&2
  exit
fi

# Remerge forgotten binaries!
emerge -pvek world --with-bdeps y 2>&1 1>&1 | \
	awk -F "] " '/\[ebuild.+\]/ { print $2 }' | xargs | \
		xargs -r -I {} emerge -1pv {} \; emerge -1 --keep-going {} \;