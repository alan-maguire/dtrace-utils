#!/bin/bash
#
# Oracle Linux DTrace.
# Copyright (c) 2024, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at
# http://oss.oracle.com/licenses/upl.
#
# There are various tests that use the usdt-tst-defer trigger.  As a
# baseline, let us run the trigger without enabling any USDT probes
# and check that the counts are as expected.

dtrace=$1
trigger=`pwd`/test/triggers/usdt-tst-defer

# Set up test directory.

DIRNAME=$tmpdir/defer-nodtrace.$$.$RANDOM
mkdir -p $DIRNAME
cd $DIRNAME

# Make a private copy of the trigger executable so that we get our
# own DOF stash.

cp $trigger main

# Check that the is-enabled probes are false when the USDT probes are not enabled.
# That is, nphase1foo == nphase1bar == nphase2foo == nphase2bar == 0.
# Also, nphase2 == 10.
# Note that nphase1 will be undefined.

./main > main.out &
pid=$!
sleep 1
kill -USR1 $pid
wait

echo "$pid: undefined 0 0 10 0 0" > main.out.expected
if ! awk '{ $2 = "undefined"; print }' main.out | diff -q - main.out.expected; then
	echo program output looks wrong for the no-DTrace case
	echo === got ===
	cat main.out
	echo === expected ===
	cat main.out.expected
	exit 1
fi

echo success

exit 0
