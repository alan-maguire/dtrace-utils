#!/bin/bash
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright 2013 Oracle, Inc.  All rights reserved.
# Use is subject to license terms.
#

# @@timeout: 20

##
#
# ASSERTION:
# Testing -ln option with a valid probe name.
#
# SECTION: dtrace Utility/-ln Option
#
##

if [ $# != 1 ]; then
	echo expected one argument: '<'dtrace-path'>'
	exit 2
fi

dtrace=$1

$dtrace $dt_flags -ln BEGIN
$dtrace $dt_flags -ln :read:
$dtrace $dt_flags -ln syscall::read:
$dtrace $dt_flags -ln ::read:
$dtrace $dt_flags -ln syscall:vmlinux:'read*':
$dtrace $dt_flags -ln profile:::tick-1000
$dtrace $dt_flags -ln read: -n write:
$dtrace $dt_flags -ln read: -n fight:
$dtrace $dt_flags -ln 'syscall::read*:' -n fight:
$dtrace $dt_flags -ln fight: -n write:
$dtrace $dt_flags -ln read:'{printf("FOUND");}'
$dtrace $dt_flags -ln read:entry'{printf("FOUND");}'
$dtrace $dt_flags -ln BEGIN'{printf("FOUND");}'
$dtrace $dt_flags -ln BEGIN'/probename=="entry"/{printf("FOUND");}'
exit 0
