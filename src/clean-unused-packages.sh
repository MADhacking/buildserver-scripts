#! /bin/bash

# Source the profile
source /etc/profile &>/dev/null

# Check to make sure we are being run from inside the buildspace.
if [ -z "$BUILDSPACE_NAME" ]; then
  echo "ERROR: $0 should only be run from inside a buildspace!" >&2
  exit
fi

# Remerge forgotten binaries!
# emerge -pvek world --with-bdeps y 2>&1 1>&1 | grep ebuild | awk '{ print "="$4 }' | xargs emerge -1
# emerge -pvek world --with-bdeps y 2>&1 1>&1 | awk '/\[ebuild/ { print "="$4 }' | xargs emerge -1

# Store current directory, repeatedly delete least recently accessed 10 files from 
# packages directories until there is sufficient free space, restore current 
# directory and fix package cache if we deleted anything. 
echo -n "Cleaning unused packages..." 
pushd /mnt/portage/packages > /dev/null 
touch /tmp/timestamp 1>/dev/null
emerge -pvek world --with-bdeps y 2>&1 1>&1 | awk -F "] " '/\[binary.+\]/ { print $2 }' | awk '{print $1 ".tbz2"}' | xargs -n 128 touch -a -c
find -type f ! -anewer /tmp/timestamp -delete 1>/dev/null
rm /tmp/timestamp 1>/dev/null
popd > /dev/null 
rm /mnt/portage/packages/Packages -f
echo -ne "done.\nFixing package cache..." 
emaint --fix binhost 1>/dev/null 
echo "done." 




