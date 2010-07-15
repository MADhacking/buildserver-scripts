#! /bin/bash

function helpscreen
{
	echo "Usage: merge-new-configs [OPTION]..."
#	echo ""
	echo
	echo "  -f \"FILES\", --files \"FILES\"    use the file list specified in FILES"
	echo "                                 instead of using configuration file"
	echo "  -g FILE, --cfg-file FILE       use the configuration specified in FILE"
	echo "                                 instead of the default location ${CFGFILE}"
}

# Init local vars
CFGFILE=/etc/merge-new-configs

# If the config file exists and we can read it do so
[[ -r ${CFGFILE} ]] && source ${CFGFILE}

# Process command line switches
while [ $# -gt 0 ]
do
	case $1 in
		-f|--files)
			FILES=$2
			shift 2
	    ;;
		-g|--cfg-file)
			CFGFILE=$2
			shift 2
	    ;;
				
		*)
			helpscreen
			shift 1
			exit
		;;
	esac
done

# Source the profile
source /etc/profile &>/dev/null

# Check to make sure we are being run from inside the buildspace.
if [ -z "$BUILDSPACE_NAME" ]; then
	echo "ERROR: $0 should only be run from inside a buildspace!" >&2
	exit 1
fi

# Check config
if [[ -z ${FILES} ]]; then
	if [[ ! -r ${CFGFILE} ]]; then
		echo "Error: No config file (or no read permissions) at ${CFGFILE} and not all required options were specified"
		exit 2
	fi
	echo "Error: You have no FILES set in ${CFGFILE} and none were specified" 1>&2
	exit 2
fi	

# Loop through the files above searching for any configuration files which
# match.  If any are found for that file display them and delete them.
echo "Searching for new configurations for:"
for F in ${FILES}; do
	echo -n "    ${F} : "
	FTD=$(find /etc -name "._cfg*${F}*" | xargs -r)
	if [ -z ${FTD} ]; then
		echo "none."
	else
		echo ${FTD}
		rm -f ${FTD}
	fi
done
echo

# Now that we have removed any configuration files we do not want we can
# use etc-update to complete the job.
echo -e "-5\n" | etc-update
