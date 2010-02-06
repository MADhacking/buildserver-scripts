#! /bin/bash

# Source the profile 
source /etc/profile &>/dev/null 

# Check to make sure we are NOT being run from inside the buildspace.
if [ -n "$BUILDSPACE_NAME" ]; then
  echo "ERROR: $0 should NOT be run from inside a buildspace!" >&2
  exit
fi

chroot /mnt/buildspaces/x86-64bit-server /usr/local/sbin/do-update.sh
chroot /mnt/buildspaces/x86-64bit-workstation /usr/local/sbin/do-update.sh

linux32 chroot /mnt/buildspaces/x86-32bit-server /usr/local/sbin/do-update.sh
linux32 chroot /mnt/buildspaces/x86-32bit-workstation /usr/local/sbin/do-update.sh
