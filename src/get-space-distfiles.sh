#! /bin/bash

# Source the profile
source /etc/profile &>/dev/null

# Check to make sure we are being run from inside the buildspace.
if [ -z "$BUILDSPACE_NAME" ]; then
  echo "ERROR: $0 should only be run from inside a buildspace!" >&2
  exit
fi

# Get size of downloads for this update
# sizeStr="Total: 3 packages (3 upgrades), Size of downloads: 1,497 kB"
sizeStr=`emerge -pvuDN world | grep "Size of downloads:"`

# Split result string
oIFS=$IFS
IFS=':' split1=($sizeStr)
IFS=' ' split2=(${split1[2]})
IFS=$oIFS

# Get size and units
reqSize=${split2[0]//,/}
units=${split2[1]}

# If size is 0 then we're done
if [ $(($reqSize)) == 0 ]; then
  echo 0
  exit
fi

# Add 10%
reqSize=$(( $reqSize + ${reqSize:0:$(( ${#reqSize} - 1 ))} ))

# Calculate in bytes
shopt -s nocasematch
case "$units" in
  "kb") reqSize=$(( $reqSize * 1024 )) ;;
  "mb") reqSize=$(( $reqSize * 1024 * 1024 )) ;;
  "gb") reqSize=$(( $reqSize * 1024 * 1024 * 1024 )) ;;
esac
shopt -u nocasematch

# Display result
echo $(( 0 + reqSize ))

