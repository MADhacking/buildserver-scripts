#! /bin/bash

patchroot=/mnt/repositories/patches

pushd $patchroot > /dev/null

patches=`find -type f | sort`
for p in $patches; do
        pushd /mnt/repositories/testing/portage > /dev/null
        echo "Applying patch $p to :"
        files=`find -path "$p" | sort`
        for f in $files; do
                echo "    $f"
                patch -s -F 3 $f < $patchroot/$p
        done
done

popd > /dev/null