/*
 * Oracle Linux DTrace.
 * Copyright (c) 2024, Oracle and/or its affiliates. All rights reserved.
 * Licensed under the Universal Permissive License v 1.0 as shown at
 * http://oss.oracle.com/licenses/upl.
 */

/*
 * ASSERTION: simple rawfbt provider arg0 and probefunc print test.
 */

#pragma D option quiet
#pragma D option statusrate=10ms

rawfbt::do_sys_poll:return
/arg1 == 0/
{
	printf("%s %x returned 0", probefunc, arg0);
	exit(0);
}
