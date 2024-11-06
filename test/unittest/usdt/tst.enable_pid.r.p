#!/usr/bin/awk -f
{
	# ignore the specific process ID
	gsub(/test_prov[0-9]+/, "test_provNNN");

	print;
}
