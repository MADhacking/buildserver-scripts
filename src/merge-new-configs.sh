#! /bin/bash

# Source the profile
source /etc/profile &>/dev/null

# Check to make sure we are being run from inside the buildspace.
if [ -z "$BUILDSPACE_NAME" ]; then
  echo "ERROR: $0 should only be run from inside a buildspace!" >&2
  exit
fi

# This is the list of files to protect.
files="make.conf resolv.conf "

# Loop through the files above searching for any configuration files which
# match.  If any are found for that file display them and delete them.
echo "Searching for new configurations for:"
for f in $files; do
	echo -n "    $f : "
	ftd=$(find /etc -name "._cfg*$f*" | xargs)
	if [ -n "$ftd" ]; then
		echo "none."
	else
		echo $ftd
		# rm -f $ftd
	fi
done

# Now that we have removed any configuration files we do not want we can
# use etc-update to complete the job.
echo -e "-1\n" | etc-update
