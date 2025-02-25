/*
 * Oracle Linux DTrace.
 * Copyright (c) 2025, Oracle and/or its affiliates. All rights reserved.
 * Licensed under the Universal Permissive License v 1.0 as shown at
 * http://oss.oracle.com/licenses/upl.
 */

/*
 * ASSERTION: The trace() action prints an array correctly.
 *
 * SECTION: Actions and Subroutines/trace()
 */

short n[5];

BEGIN
{
	n[0] = 0x1234;
	n[1] = 0x5678;
	n[2] = 0x0000;
	n[3] = 0x8765;
	n[4] = 0x4321;
	trace(n);
	exit(0);
}
