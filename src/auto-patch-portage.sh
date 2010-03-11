#! /bin/bash

patchroot=/mnt/repositories/patches

pushd $patchroot > /dev/null

patches=`find -type f`
for p in patches; do
	pushd /mnt/repositories/testing/portage > /dev/null
	files=`find -path "$p"`
	for f in files; do
		patch $f < $patchroot/$p
	done
done	

popd > /dev/null