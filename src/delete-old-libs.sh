#! /bin/bash

# Path to the build log.
blp="/var/log/autobuild/build_phase.out.log"

# Search the build log and display any libraries for which a revdep-rebuild is suggested.
echo "Libraries needing revdep-rebuild:" 
awk '/\*.+revdep-rebuild --library/ { x=1; do { x++; } while ($(x-1) != "--library") print "    " $x }' < $blp

# Search the build log and display any libraries which can be safely removed.
echo -e "\nLibraries which can be safely deleted:"
awk '/\*.+\#.+rm/ { print "    " $4 }' < $blp

# Search the build log for libraries for which a revdep-rebuild is suggested and run it.
echo -e "\nStarting revdep-rebuild of packages using above libraries...\n\n"  
awk '/\*.+revdep-rebuild --library/ { x=1; do { x++; } while ($(x-1) != "--library") print $x }' < $blp | xargs -r -n 1 revdep-rebuild --library 

# Search the build log and delete any libraries which can be safely removed.
echo -e "\n\nDeleting old libraries...\n\n"  
awk '/\*.+\#.+rm/ { print $4 }' < $blp | xargs -r rm -f
	