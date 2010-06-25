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
echo "Cleaning unused packages..." 
pushd /mnt/portage/packages > /dev/null 
touch /tmp/timestamp 1>/dev/null
qlist -I -v | awk '{print $1 ".tbz2"}' | xargs -r -n 128 touch -a -c
find -type f ! -anewer /tmp/timestamp
find -type f ! -anewer /tmp/timestamp -delete 1>/dev/null
rm /tmp/timestamp 1>/dev/null
popd > /dev/null 
echo "...done"
