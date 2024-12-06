#!/bin/sh
grep -v '^ *ID' | sed 's,^[0-9]*,ID,; s,prov\(.\)[0-9]*,prov\1PID,; s,  *, ,g'
