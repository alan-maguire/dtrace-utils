#!/bin/bash

#
# Oracle Linux DTrace.
# Copyright (c) 2017, 2024, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at
# http://oss.oracle.com/licenses/upl.

#
# Script invoked by unit tests to generate IO
#

if (( $# < 4 )); then
        echo "expected 5 or more arguments: <tempfile> <filesize> <mountcmd> <mountdir> [<mountarg1>] [<mountarg2>]" >&2
        exit 2
fi

tempfile=$1
filesize=$2
mountcmd=$3
mountdir=$4
mountarg1=${5-""}
mountarg2=${6-""}

# do writes
dd if=/dev/urandom of=$tempfile count=$filesize bs=1 status=none
if [ $? -ne 0 ]; then
	echo ERROR dd
	exit 1
fi

# flush cache and remount the file system to force the IO
ntries=3
while [ $ntries -gt 0 ]; do
	umount $mountdir >& /dev/null
	if [ $? -eq 0 ]; then
		break
	fi
	sleep 1
	ntries=$(($ntries - 1))
done
if [ $ntries -eq 0 ]; then
	echo ERROR umount
	exit 1
fi

echo 3 > /proc/sys/vm/drop_caches
$mountcmd $mountdir $mountarg1 $mountarg2
if [ $? -ne 0 ]; then
	echo ERROR $mountcmd
	exit 1
fi

# do reads
sum $tempfile > /dev/null
if [ $? -ne 0 ]; then
	echo ERROR sum
	exit 1
fi
