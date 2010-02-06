#! /bin/bash

# Source the profile
source /etc/profile &>/dev/null

# Check to make sure we are being run from inside the buildspace.
if [ -z "$BUILDSPACE_NAME" ]; then
  echo "ERROR: $0 should only be run from inside a buildspace!" >&2
  exit
fi

# Store current directory, repeatedly delete oldest 20 files from distfiles
# directory until there is sufficient free space, restore current directory.
pushd /mnt/portage/distfiles > /dev/null 

if [ `df . -P -B 1 2>/dev/null | tail -1 | awk '{print $4}'` -gt $(($1)) ]; then
  exit
fi

echo -n "Freeing space for distfiles..."
while [ `df . -P -B 1 2>/dev/null | tail -1 | awk '{print $4}'` -lt $(($1)) ] 
do 
  rm `ls -1 --time=atime --sort=time --reverse | head --lines=20` 
  echo -n "."
done 
popd > /dev/null
echo "done."
