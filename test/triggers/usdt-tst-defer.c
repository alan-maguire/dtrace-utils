/*
 * Oracle Linux DTrace.
 * Copyright (c) 2024, Oracle and/or its affiliates. All rights reserved.
 * Licensed under the Universal Permissive License v 1.0 as shown at
 * http://oss.oracle.com/licenses/upl.
 */

/*
 * The main characteristic of this trigger code is that it allows deferred
 * DTrace detection of the trigger.  That is, the trigger spins in "phase 1",
 * waiting for DTrace to detect it and send it USR1.  Only then does "phase 2"
 * run a short workload to completion.
 */

#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <signal.h>
#include "usdt-tst-defer-prov.h"

static int phase = 1;

static void
interrupt(int sig)
{
	phase = 2;
}

int
main(int argc, char **argv)
{
	struct sigaction act;
	int i;
	int nphase1 = 0, nphase1foo = 0, nphase1bar = 0;
	int nphase2 = 0, nphase2foo = 0, nphase2bar = 0;

	/* set the handler to listen for SIGUSR1 */
	act.sa_handler = interrupt;
	act.sa_flags = 0;
	if (sigaction(SIGUSR1, &act, NULL)) {
		printf("set handler failed\n");
		return 1;
	}

	/* in phase 1, loop on probe "foo" to wait on USR1 */
	while (phase == 1) {
		nphase1++;
		if (TESTPROV_FOO_ENABLED()) {
			nphase1foo++;
			phase = 2;
		}
		if (TESTPROV_BAR_ENABLED()) {
			nphase1bar++;
			phase = 2;
		}
		TESTPROV_FOO();
	}

	/* wait for probes to get set up */
	usleep(100000);

	/* in phase 2, just loop over probe "bar" a fixed number of times */
	for (i = 0; i < 10; i++) {
		nphase2++;
		usleep(2000);
		if (TESTPROV_FOO_ENABLED())
			nphase2foo++;
		usleep(2000);
		if (TESTPROV_BAR_ENABLED())
			nphase2bar++;
		usleep(2000);
		TESTPROV_BAR(i, i + 2, i * 2);
	}

	printf("%d: %d %d %d %d %d %d\n", getpid(),
	    nphase1, nphase1foo, nphase1bar, nphase2, nphase2foo, nphase2bar);

	return 0;
}
