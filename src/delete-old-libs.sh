#! /bin/bash

# Path to the build log.
blp="/var/log/autobuild/build_phase.out.log"

# Search the build log and display any libraries for which a revdep-rebuild is suggested.
echo "Libraries needing revdep-rebuild:" 
awk '/\*.+revdep-rebuild --library/ { print "    " $5 }' < $blp
echo

# Search the build log and display any libraries which can be safely removed.
echo "Libraries which can be safely deleted:"
awk '/\*.+\#.+rm/ { print "    " $4 }' < $blp
echo 

# Search the build log for libraries for which a revdep-rebuild is suggested and run it.
echo -e "Starting revdep-rebuild of packages using above libraries...\n\n"  
awk '/\*.+revdep-rebuild --library/ { print "    " $5 }' < $blp | xargs -r -n 1 revdep-rebuild --library 

# Search the build log and delete any libraries which can be safely removed.
echo -e "\n\nDeleting old libraries...\n\n"  
awk '/\*.+\#.+rm/ { print $4 }' < $blp | xargs -r rm -f
	