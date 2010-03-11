#! /bin/bash

patchroot=/mnt/repositories/patches

pushd $patchroot > /dev/null
patches=`find -type f | sort`
popd > /dev/null

pushd /mnt/repositories/testing/portage > /dev/null
for p in "$patches"; do
        echo "    Applying patch $p to :"
        files=`find -path "$p" | sort`
        for f in $files; do
                echo -n "        $f"
                patch -s -N -F 3 $f < $patchroot/$p
		if [ "${f##*.}" == "ebuild" ]; then
			echo -n " - rebuilding manifest"
			ebuild $f digest > /dev/null
		fi
		echo
        done
done
popd > /dev/null
