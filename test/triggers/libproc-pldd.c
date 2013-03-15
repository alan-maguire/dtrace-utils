/*
 * CDDL HEADER START
 *
 * The contents of this file are subject to the terms of the
 * Common Development and Distribution License (the "License").
 * You may not use this file except in compliance with the License.
 *
 * You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
 * or http://www.opensolaris.org/os/licensing.
 * See the License for the specific language governing permissions
 * and limitations under the License.
 *
 * When distributing Covered Code, include this CDDL HEADER in each
 * file and include the License file at usr/src/OPENSOLARIS.LICENSE.
 * If applicable, add the following below this CDDL HEADER, with the
 * fields enclosed by brackets "[]" replaced with your own identifying
 * information: Portions Copyright [yyyy] [name of copyright owner]
 *
 * CDDL HEADER END
 */

/*
 * Copyright 2013 Oracle, Inc.  All rights reserved.
 * Use is subject to license terms.
 */

#include <sys/ptrace.h>
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <string.h>

#include <libproc.h>
#include <rtld_db.h>

static int libs_seen;

static int
print_ldd(const rd_loadobj_t *loadobj, size_t num, void *p)
{
	struct ps_prochandle *P = p;
	char buf[PATH_MAX];

	if (Pread_string(P, buf, sizeof (buf), loadobj->rl_nameaddr) < 0) {
		fprintf(stderr, "Failed to read string at %lx\n",
		    loadobj->rl_nameaddr);
		return (0);
	}

	printf("%s: dyn 0x%lx, bias 0x%lx, LMID %li\n", buf, loadobj->rl_dyn,
	    loadobj->rl_base, loadobj->rl_lmident);

	libs_seen++;
	return (1);
}

static int
note_ldd(const rd_loadobj_t *loadobj, size_t num, void *p)
{
	struct ps_prochandle *P = p;
	char buf[PATH_MAX];

	if (Pread_string(P, buf, sizeof (buf), loadobj->rl_nameaddr) < 0) {
		fprintf(stderr, "Failed to read string at %lx\n",
		    loadobj->rl_nameaddr);
		return (0);
	}

	libs_seen++;
	return (1);
}

static int
do_nothing(const rd_loadobj_t *loadobj, size_t num, void *p)
{
    return (1);
}
struct rd_agent {
	struct ps_prochandle *P;	/* pointer back to our ps_prochandle */
	/* other stuff ... */
};

int
main(int argc, char *argv[])
{
	long pid;
	struct ps_prochandle *P;
	struct rd_agent *rd;
	int err;
	int really_seen;

	if (argc < 2) {
		fprintf(stderr, "Syntax: libproc-pldd PID | process [args ...]\n");
		exit(1);
	}

	pid = strtol(argv[1], NULL, 10);

	if (!pid)
		P = Pcreate(argv[1], &argv[1], &err, 0);
	else
		P = Pgrab(pid, &err);

	if (!P) {
		fprintf(stderr, "Cannot execute: %s\n", strerror(err));
		exit(1);
	}

	rd = rd_new(P);
	if (!rd) {
		fprintf(stderr, "Initialization failed.\n");
		return (1);
	}

	/*
	 * Iterate immediately after initialization to enure that, whether we
	 * get RD_OK or RD_NOMAPS, we do not get a crash.  (Note: this may
	 * resume, briefly, in order to ensure that we get a consistent state.)
	 */
	switch (rd_loadobj_iter(rd, do_nothing, P)) {
	case RD_OK:
	case RD_NOMAPS:
		break;
	case RD_ERR:
		fprintf(stderr, "Unknown error.\n");
		break;
	}

	Ptrace_set_detached(P, 1);
	Puntrace(P, 0);

	/*
	 * Now iterate and print.
	 */

	while (rd_loadobj_iter(rd, print_ldd, P) == RD_NOMAPS)
		sleep (1);

	really_seen = libs_seen;

	/*
	 * Kill rtld_db (disconnecting from the ptrace()d process),
	 * then recreate it and iterate, ensuring that librtld_db can reattach
	 * on its own if it needs to.
	 */

	rd_delete(rd);
	rd = rd_new(P);
	if (!rd) {
		fprintf(stderr, "rd reinitialization failed.\n");
		return (1);
	}

	while (rd_loadobj_iter(rd, note_ldd, P) == RD_NOMAPS)
		sleep (1);

	printf("%i libs seen.\n", really_seen);

	if (libs_seen != really_seen * 2)
	    fprintf(stderr, "Post-reattachment initialization saw %i libs, "
		"where first scan saw %i\n", libs_seen - really_seen,
		really_seen);

	Prelease(P, (pid == 0));

	return (0);
}