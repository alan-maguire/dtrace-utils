/*
 * Oracle Linux DTrace.
 * Copyright (c) 2024, Oracle and/or its affiliates. All rights reserved.
 * Licensed under the Universal Permissive License v 1.0 as shown at
 * http://oss.oracle.com/licenses/upl.
 */

/*
 * A trigger with multiple providers in it.
 */
#include <stdio.h>
#include <unistd.h>
#include "usdt-tst-multiprovider-prov.h"

int main(int argc, char **argv)
{
	PROVA_ENTRYA();
	PROVB_ENTRYB();
	PROVB_ENTRYC(666, "foo");
	PROVC_ENTRYD();
	usleep(5 * 1000 * 1000);
	return 0;
}
