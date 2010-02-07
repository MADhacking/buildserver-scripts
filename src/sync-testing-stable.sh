#! /bin/bash

# Source the profile
source /etc/profile &>/dev/null

# Check to make sure we are NOT being run from inside the buildspace.
if [ -n "$BUILDSPACE_NAME" ]; then
  echo "ERROR: $0 should NOT be run from inside a buildspace!" >&2
  exit
fi

echo "Synchronising testing tree to stable tree:"

echo -n "Synchronising portage..."
rsync /mnt/repositories/testing/portage/ /mnt/repositories/stable/portage/ --quiet --delete --archive --no-D
echo "...done."

echo -n "Synchronising packages..."
rsync /mnt/repositories/testing/packages/ /mnt/repositories/stable/packages/ --quiet --delete --archive --no-D
echo "...done."

#echo -n "Synchronising kernels..."
#rsync /mnt/repositories/testing/kernels/ /mnt/repositories/stable/kernels/ --quiet --delete --archive --no-D
#echo "...done."
