/*
 * Oracle Linux DTrace.
 * Copyright (c) 2024, Oracle and/or its affiliates. All rights reserved.
 * Licensed under the Universal Permissive License v 1.0 as shown at
 * http://oss.oracle.com/licenses/upl.
 */

/*
 * ASSERTION: rawfbt provider return probe
 */

/* @@runtest-opts: -Z */
/* @@trigger: pid-tst-args1 */

#pragma D option quiet
#pragma D option statusrate=10ms

rawfbt::SyS_ioctl:return,
rawfbt::__arm64_sys_ioctl:return,
rawfbt::__x64_sys_ioctl:return
{
	exit(0);
}
