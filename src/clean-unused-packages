#! /bin/bash

# Source the profile
source /etc/profile &>/dev/null

# Check to make sure we are being run from inside the buildspace.
if [ -z "$BUILDSPACE_NAME" ]; then
  echo "ERROR: $0 should only be run from inside a buildspace!" >&2
  exit
fi

# Store current directory, repeatedly delete least recently accessed 10 files from 
# packages directories until there is sufficient free space, restore current 
# directory and fix package cache if we deleted anything. 
echo -n "Cleaning unused packages..." 
pushd /mnt/portage/packages > /dev/null 
touch /tmp/timestamp 1>/dev/null
touch -a -c `emerge -pveK world --with-bdeps y | awk '/\[binary/ { print $4 ".tbz2" }'` 1>/dev/null
find -type f ! -anewer /tmp/timestamp -delete 1>/dev/null
rm /tmp/timestamp 1>/dev/null
popd > /dev/null 
rm /mnt/portage/packages/Packages
echo -ne "done.\nFixing package cache..." 
emaint --fix binhost 1>/dev/null 
echo "done." 
