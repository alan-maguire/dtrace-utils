#!/bin/bash
#
# Oracle Linux DTrace.
# Copyright (c) 2024, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at
# http://oss.oracle.com/licenses/upl.
#
# This test verifies that dtrace will not run a destructive script
# for USDT probes if -w is not specified.
#
# Specifically, the script is launched with -Z and no USDT processes are
# initially present.  Only once a USDT process is detected does dtrace
# fail due to the destructive action.

dtrace=$1
trigger=`pwd`/test/triggers/usdt-tst-defer

# Set up test directory.

DIRNAME=$tmpdir/Z_no-w.$$.$RANDOM
mkdir -p $DIRNAME
cd $DIRNAME

# Make a private copy of the trigger executable so that we get our
# own DOF stash.

cp $trigger main

# Run dtrace.

$dtrace $dt_flags -Zq -o dtrace.out -n '
testprov*:::foo
{
	raise(SIGUSR1);
}' &
dtpid=$!
sleep 4
if [[ ! -d /proc/$dtpid ]]; then
	echo ERROR dtrace died prematurely
	exit 1
fi

# Start a trigger process.

echo dtrace is running so start the trigger
./main > main.out &
pid=$!

# Check again if dtrace is still running.

sleep 2
if [[ ! -d /proc/$dtpid ]]; then
	echo dtrace died as expected after trigger started
else
	echo dtrace is unexpectedly still running
	kill -9 $dtpid
	wait    $dtpid
fi

# Tell the trigger to proceed to completion.

kill -USR1 $pid
wait       $pid

exit 1
