#!/bin/sh

# Search for the value of VLS_LOCK_HOSTNAME and then replace
# the line at the end of file that begins with 0 as this line
# should be the default lock selector in HEX

HOSTNAME_HEX=`grep "VLS_LOCK_HOSTNAME" echoid.dat | awk '{print $3}'`
sed -i "/^0/ s/0x3D9F$/${HOSTNAME_HEX}/" echoid.dat

