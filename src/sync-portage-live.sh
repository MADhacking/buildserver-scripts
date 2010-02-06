#! /bin/bash

# Source the profile
source /etc/profile &>/dev/null

# Check to make sure we are NOT being run from inside the buildspace.
if [ -n "$BUILDSPACE_NAME" ]; then
  echo "ERROR: $0 should NOT be run from inside a buildspace!" >&2
  exit
fi

echo -n "Beginning synchronisation of the live portage tree..."
rsync rsync.gentoo.org::gentoo-portage /mnt/repositories/live/portage --quiet --archive --no-D --delete-during
echo "...done."
