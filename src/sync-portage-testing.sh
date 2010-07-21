#! /bin/bash 

# Source the profile
source /etc/profile &>/dev/null

# Check to make sure we are NOT being run from inside the buildspace.
if [ -n "$BUILDSPACE_NAME" ]; then
  echo "ERROR: $0 should NOT be run from inside a buildspace!" >&2
  exit
fi

echo -n "Synchronising the testing portage tree..." 
rsync /mnt/repositories/live/portage/ /mnt/repositories/testing/portage/ --quiet --delete --archive --no-D
echo "...done." 

echo
auto-patch-portage --sync --copy-files --apply-patches
echo

chroot /mnt/buildspaces/x86-64bit-server /usr/local/sbin/update-portage-metadata
chroot /mnt/buildspaces/x86-64bit-workstation /usr/local/sbin/update-portage-metadata

linux32 chroot /mnt/buildspaces/x86-32bit-server /usr/local/sbin/update-portage-metadata
linux32 chroot /mnt/buildspaces/x86-32bit-workstation /usr/local/sbin/update-portage-metadata


