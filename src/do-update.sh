#! /bin/bash

# Update environment and source the profile
env-update --no-ldconfig &>/dev/null
source /etc/profile &>/dev/null

# Include and initialise logging
source _outcatcher.sh
init_logging "/var/log/autobuild"

# Check to make sure we are being run from inside the buildspace.
if [[ -z "$BUILDSPACE_NAME" ]]; then
  echo "ERROR: $0 should only be run from inside a buildspace!" >&2
  exit 1
fi

# Clean the portage and binary package temporary directory
PTD=$(portageq envvar PORTAGE_TMPDIR)
[[ -z ${PTD} || ! $? ]] && echo "ERROR: Unable to locate PORTAGE_TMPDIR" >&2 && exit 2
rm -rf ${PTD}/portage/* ${PTD}/binpkgs/*
[[ ! $? ]] && echo "ERROR: Unable to clean ${PTD}/portage" >&2 && exit 3
rm -rf ${PTD}/binpkgs/*
[[ ! $? ]] && echo "ERROR: Unable to clean ${PTD}/binpkgs" >&2 && exit 3

# If we are not being run from a TTY then redirect output to ~/update.out
tty -s
tty=$?
[[ $tty -gt 0 ]] && exec 1> ~/update.out.log

echo "Starting automated update of $BUILDSPACE_NAME buildspace."

# Ensure free space is available for distfiles
free-distfiles-space --free-delete

# Do a pretend update for the logs
echo -n "Performing pretend update..."
exec_and_log pretend_update "emerge -pvuDN world"
(( ! $? )) && echo "done." || echo "failed."

# Fetch distfiles
echo -n "Fetching required distfiles..."
exec_and_log fetch_phase "emerge -uDN world --fetchonly"
if [[ $? -gt 0 ]]; then
	echo "failed!"
else
	echo "done."

	# Build updated packages
	echo -n "Building updated packages..."
	exec_and_log build_phase "emerge -uDN world --keep-going"
	(( ! $? )) && echo "done." || echo "failed."
	
	# Store any new news items for email attachment later
	echo -n "Checking for news..."
	exec_and_log news "eselect news read new"
	(( ! $? )) && echo "done." || echo "failed."

	# Merge default configurations
	echo -n "Merging new default configurations..."
	exec_and_log config_merge "merge-new-configs.sh"
	(( ! $? )) && echo "done." || echo "failed."
	
	# Clean orphaned dependencies
	echo -n "Cleaning orphaned dependencies..."
	exec_and_log depclean "emerge --depclean"
	(( ! $? )) && echo "done." || echo "failed."
	
	# Fix broken .la files
	echo -n "Fixing broken .la files..."
	exec_and_log lafilefixer "lafilefixer --justfixit"
	(( ! $? )) && echo "done." || echo "failed."
	
	# Remove old libraries kept by preserve-libs
	echo -n "Removing redundant libraries..."
	exec_and_log delete_old_libs "delete-old-libs.sh"
	(( ! $? )) && echo "done." || echo "failed."
	
	# Rebuild broken binaries
	echo -n "Rebuilding broken binaries..."
	exec_and_log revdep_rebuild_p1 "revdep-rebuild -i -p -P"
	[[ -e /var/cache/revdep-rebuild/3_broken.rr ]] && exec_and_log revdep_rebuild_p2 "revdep-rebuild -P"
	(( ! $? )) && echo "done." || echo "failed."
	
	# Ensure any python packages broken by an update are rebuilt
	echo -n "Rebuilding broken python packages..."
	exec_and_log python_updater "python-updater --disable-manual"
	(( ! $? )) && echo "done." || echo "failed."
	
	# Ensure any perl packages broken by an update are rebuilt
	echo -n "Rebuilding broken perl packages..."
	exec_and_log perl_cleaner "perl-cleaner ph-clean modules"
	(( ! $? )) && echo "done." || echo "failed."
	
	# Ensure all required distfiles have been accessed
	echo -n "Touching all required distfiles..."
	emerge -e --fetchonly world --with-bdeps y &> /dev/null
	(( ! $? )) && echo "done." || echo "failed."
	
	# Remove unused binary packages
	echo -n "Cleaning unused packages..." 
	exec_and_log clean_unused "clean-unused-packages.sh"
	(( ! $? )) && echo "done." || echo "failed."

	# Fix the package cache for the binhost
	echo -n "Fixing package cache..." 
	rm /mnt/portage/packages/Packages -f
	emaint --fix binhost 1>/dev/null 
	(( ! $? )) && echo "done." || echo "failed."

	echo -e "Automated update of $BUILDSPACE_NAME buildspace completed.\n"
fi

# Bzip any log files larger than 100k
bzip_large_logs 102400

# If we are being run from cron then send email logs to the administrator and
# end the redirect of 1&2 otherwise display summary message.
get_log_files logfiles
if [[ $tty -gt 0 ]]; then
	mutt -s "Automated update of $BUILDSPACE_NAME" \
         -a ${logfiles} \
         -- root < ~/update.out.log
  	exec 1>&1
	(( ! $? )) && clean_up_logs
else
	echo "Logs can be found at ${logfiles}"
fi
