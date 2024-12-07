/*
 * Oracle Linux DTrace.
 * Copyright (c) 2024, Oracle and/or its affiliates. All rights reserved.
 * Licensed under the Universal Permissive License v 1.0 as shown at
 * http://oss.oracle.com/licenses/upl.
 */

/*
 * ASSERTION: The rawfbt provider can probe return of synthetic functions.
 */

rawfbt::finish_task_switch.isra.0:return {
	exit(0);
}
