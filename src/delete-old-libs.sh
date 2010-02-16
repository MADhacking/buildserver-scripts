#! /bin/bash

#echo "Libraries needing revdep-rebuild:" 
#awk '/\*.+\#.+revdep-rebuild --library/ { print "    " $5 }' < build_phase.out.log

echo -e "Removing redundant libraries...\n"
awk '/\*.+\#.+rm/ { print "    " $4 }' < /var/log/autobuild/build_phase.out.log
awk '/\*.+\#.+rm/ { print $4 }' < /var/log/autobuild/build_phase.out.log | xargs rm -f
echo -n "...done."	