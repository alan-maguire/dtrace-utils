#!/bin/bash
# Licensed under the Universal Permissive License v 1.0 as shown at
# http://oss.oracle.com/licenses/upl.
#
# SKIP if gfs2.ko not found (exit 2)
[[ ! -e /lib/modules/$(uname -r)/kernel/fs/gfs2/gfs2.ko ]] &&
[[ ! -e /lib/modules/$(uname -r)/kernel/fs/gfs2/gfs2.ko.xz ]] && exit 2;
exit 0
