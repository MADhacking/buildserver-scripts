#! /bin/bash

# Update environment and source the profile
env-update &>/dev/null
source /etc/profile &>/dev/null

# Check to make sure we are being run from inside the buildspace.
if [ -z "$BUILDSPACE_NAME" ]; then
  echo "ERROR: $0 should only be run from inside a buildspace!" >&2
  exit
fi

# Clean log files, if they exist.
rm -f ~/fetchlog.txt ~/buildlog.txt ~/depcleanlog.txt ~/revdeplog.txt

# Clean the portage and binary package temporary directory
rm -rf /var/tmp/portage/* /var/tmp/binpkgs/*

# If we are not being run from a TTY then redirect output to ~/update.out
tty -s
tty=$?
[ $tty -gt 0 ] && exec 1> ~/update.out

echo "Starting automated update of $BUILDSPACE_NAME buildspace."

# Get free space required for updates
echo -n "Calculating required disk space..."
reqSpace=`get-space-distfiles`
echo "done."

# Ensure free space is available for distfiles
free-distfiles-space $reqSpace

# Ensure free space is available for packages
# free-packages-space $(( $reqSpace / 2 ))

# Fetch distfiles
echo -n "Fetching required distfiles..."
emerge -uDN world --fetchonly &> ~/fetchlog.txt
echo "done."

# Build updated packages
echo -n "Building updated packages..."
emerge -uDN world --keep-going 2>&1 | bzip2 -9 > ~/buildlog.txt.bz2
echo "done."

# Merge default configurations

# Store any new news items for email attachment later
eselect news read new &> ~/eselect-news.txt

# Clean orphaned dependencies
echo -n "Cleaning orphaned dependencies..."
emerge --depclean &> ~/depcleanlog.txt
echo "done."

# Fix broken .la files
lafilefixer --justfixit > ~/lafilefixer.txt

# Rebuild broken binaries
echo -n "Rebuilding broken binaries..."
revdep-rebuild -i 2>&1 | bzip2 -9 > ~/revdeplog.txt.bz2
echo "done."

# Ensure any python packages broken by an update are rebuilt
echo -n "Rebuilding broken python packages..."
python-updater 2>&1 | bzip2 -9 > ~/python-updater.txt.bz2
echo "done."

# Ensure any perl packages broken by an update are rebuilt
echo -n "Rebuilding broken perl packages..."
perl-cleaner ph-clean modules 2>&1 | bzip2 -9 > ~/perl-cleaner.txt.bz2
echo "done."

# Ensure all required distfiles have been accessed
emerge -e --fetchonly world &> /dev/null

# Remove unused binary packages
clean-unused-packages

echo -e "Automated update of $BUILDSPACE_NAME buildspace completed.\n"

# If we are being run from cron then send email logs to the administrator and
# end the redirect of 1&2 otherwise display summary message.
if [ $tty -gt 0 ]; then
  mutt -s "Automated update of $BUILDSPACE_NAME" \
       -a ~/fetchlog.txt \
       -a ~/buildlog.txt.bz2 \
       -a ~/eselect-news.txt \
       -a ~/depcleanlog.txt \
       -a ~/revdeplog.txt.bz2 \
       -a ~/python-updater.txt.bz2 \
       -a ~/perl-cleaner.txt.bz2 \
       -- root < ~/update.out
  exec 1>&1
else
  echo "Logs can be found at ~/fetchlog.txt ~/buildlog.txt ~/depcleanlog.txt ~/revdeplog.txt"
fi
