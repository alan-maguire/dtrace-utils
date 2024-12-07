#!/bin/bash

# Skip test if rawfbt::finish_task_switch.isra.0:entry does not exist
msg=`$dtrace -ln rawfbt::finish_task_switch.isra.0:entry 2>/dev/null | grep -v PROVIDER`

if [[ -z "$msg" ]]; then
	echo "rawfbt::finish_task_switch.isra.0:entry not availabe"
	exit 2
fi

exit 0
