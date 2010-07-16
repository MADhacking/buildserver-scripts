#! /bin/bash

function helpscreen
{
	echo "Usage: merge-new-configs [OPTION]..."
	echo "Runs revdep-rebuild --library for libraries requiring it and deletes any"
	echo "libraries which are no longer required once the rebuild is complete"
	echo
	echo "  -l DIR, --log-path DIR         use the log directory specified in DIR"
	echo "                                 instead of that found in ${CFGFILE}"
	echo "  -p, --pretend                  do not perform any actions but list libraries"
	echo "                                 which would require the use of revdep-rebuild"
	echo "                                 and those which can be safely deleted"
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
	    -p|--pretend)
			PRETEND=1
			shift 1
	    ;;

		*)
			helpscreen
			shift 1
			exit
		;;
	esac
done

# Check to make sure we are being run from inside the buildspace.
if [ -z "$BUILDSPACE_NAME" ]; then
	echo "ERROR: $0 should only be run from inside a buildspace!" >&2
	exit 1
fi

# Check config
if [[ -z ${LOGPATH} ]]; then
	if [[ ! -r ${CFGFILE} ]]; then
		echo "Error: No config file (or no read permissions) at ${CFGFILE} and not all required options were specified" 1>&2
		exit 2
	fi
	echo "Error: You have no LOGPATH set in ${CFGFILE} and none was specified" 1>&2
	exit 2
fi	

# Path to the build log.
BLP="${LOGPATH}/build_phase.out.log"
[[ ! -r ${BLP} ]] && echo "Error: Unable to read build phase log file at ${BLP}" 1>&2 && exit 3

# Search the build log and display any libraries for which a revdep-rebuild is suggested.
echo "Libraries needing revdep-rebuild:"
REBUILDLIBS=$(awk '/revdep-rebuild --library/ { x=1; do { x++; } while ($(x-1) != "--library") print $x }' < ${BLP} )
if [[ -z ${REBUILDLIBS} ]]; then
	echo "    none"
else
	for L in ${REBUILDLIBS}; do
		echo "    ${L}"
	done
fi

# Search the build log and display any libraries which can be safely removed.
# $(awk '/\*.+\#.+rm/ { print "    " $4 }' < ${BLP} )
echo -e "\nLibraries which can be safely deleted once rebuild complete:"
DELETELIBS=$(awk '/# rm/ { x=1; do { x++; } while ($(x-1) != "rm") print $x }' < ${BLP} )
if [[ -z ${DELETELIBS} ]]; then
	echo "    none"
else
	for L in ${DELETELIBS}; do
		echo "    ${L}"
	done
fi

# If we are only pretending then this is it
[[ -n ${PRETEND} ]] && exit

# Rebuild any packages using libraries found above 
if [[ -n ${REBUILDLIBS} ]]; then
	echo -e "\nStarting revdep-rebuild of packages using above libraries:"  
	for L in ${REBUILDLIBS}; do
		echo -n "    ${L} "
		revdep-rebuild --no-progress --library ${L} \
			1>${LOGPATH}/delete_old_libs.${L}.aux.out.log 2>${LOGPATH}/delete_old_libs.${L}.aux.err.log
		(( ! $? )) && echo " - ok" || echo " - failed"
	done
fi

# Search the build log and delete any libraries which can be safely removed.
if [[ -n ${DELETELIBS} ]]; then
	echo -e "\nDeleting old libraries:"  
	for L in ${DELETELIBS}; do
		echo "    ${L}"
		rm ${L}
		(( ! $? )) && echo " - ok" || echo " - failed"
	done
fi
	