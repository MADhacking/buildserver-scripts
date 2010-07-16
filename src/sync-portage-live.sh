#! /bin/bash

function helpscreen
{
	echo "Usage: auto-patch-portage [OPTION]..."
	echo "Automatically applies patches and copies files from the location specified in"
	echo "${CFGFILE} or passed on the command line to the portage tree."
	echo
	echo "  -l, --live-repository          apply the patches found in the patch-set to"
	echo "                                 the portage tree"
	echo "  -t, --test-repository          copy the new files from the patch-set to the"
	echo "                                 portage tree"
	echo "  -s, --stable-repository        do not perform any actions but list patches"
	echo "                                 which would be applied and files which would"
	echo "                                 be copied"
	echo "  -r URL, --repositary URL       use the URL specified as the source location"
	echo "                                 when synchronising the repository instead of"
	echo "                                 that found in ${CFGFILE}"
	echo "  -s DIR, --patch-set DIR        use the patch-set directory specified in"
	echo "                                 DIR instead of that found in ${CFGFILE}"
	echo "  -t DIR, --portage-tree DIR     use the portage-tree directory specified in"
	echo "                                 DIR instead of that found in ${CFGFILE}"
	echo "  -y, --sync                     synchronise the local patch-set repository"
	echo "                                 with the remote patch-set repository"
}

# Init local vars
CFGFILE=/etc/auto-patch

# Source the profile
source /etc/profile &>/dev/null

# Check to make sure we are NOT being run from inside the buildspace.
if [ -n "$BUILDSPACE_NAME" ]; then
  echo "ERROR: $0 should NOT be run from inside a buildspace!" >&2
  exit
fi

echo -n "Beginning synchronisation of the live portage tree..."
rsync rsync.gentoo.org::gentoo-portage /mnt/repositories/live/portage --quiet --delete --archive --no-D --delete-during
echo "...done."
