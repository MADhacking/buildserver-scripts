#! /bin/bash

function helpscreen
{
	echo "Usage: merge-new-configs [OPTION]..."
#	echo ""
	echo
	echo "  -l DIR, --log-path DIR         use the log directory specified in"
	echo "                                 DIR instead of that found in ${CFGFILE}"
}

# Init local vars
CFGFILE=/etc/buildserver

# If the config file exists and we can read it do so
[[ -r ${CFGFILE} ]] && source ${CFGFILE}

# Process command line switches
while [ $# -gt 0 ]
do
	case $1 in
		-l|--log-path)
			LOGPATH=$2
			shift 2
	    ;;
				
		*)
			helpscreen
			shift 1
			exit
		;;
	esac
done

# Check config
if [[ -z ${LOGPATH} ]]; then
	if [[ ! -r ${CFGFILE} ]]; then
		echo "Error: No config file (or no read permissions) at ${CFGFILE} and not all required options were specified"
		exit 2
	fi
	echo "Error: You have no LOGPATH set in ${CFGFILE} and none was specified" 1>&2
	exit 2
fi	

# Path to the build log.
BLP="${LOGPATH}/build_phase.out.log"

# Search the build log and display any libraries for which a revdep-rebuild is suggested.
echo "Libraries needing revdep-rebuild:" 
awk '/\*.+revdep-rebuild --library/ { x=1; do { x++; } while ($(x-1) != "--library") print "    " $x }' < ${BLP}

# Search the build log and display any libraries which can be safely removed.
echo -e "\nLibraries which can be safely deleted:"
awk '/\*.+\#.+rm/ { print "    " $4 }' < ${BLP}

# Search the build log for libraries for which a revdep-rebuild is suggested and run it.
echo -e "\nStarting revdep-rebuild of packages using above libraries...\n\n"  
awk '/\*.+revdep-rebuild --library/ { x=1; do { x++; } while ($(x-1) != "--library") print $x }' < ${BLP} | xargs -r -n 1 revdep-rebuild --library 

# Search the build log and delete any libraries which can be safely removed.
echo -e "\n\nDeleting old libraries...\n\n"  
awk '/\*.+\#.+rm/ { print $4 }' < ${BLP} | xargs -r rm -f
	