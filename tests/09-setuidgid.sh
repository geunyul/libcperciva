#!/bin/sh

### Constants
c_valgrind_min=1
test_stderr="${s_basename}-stderr.txt"

# Keep this in sync with the value in tests/setuidgid/main.c!
EX_NOPERM=77

test_setuidgid_username_groupname() {
	username_groupname=$1
	pass_exitcode=$2

	setup_check_variables

	printf "=== check ${s_count}\n" >> ${test_stderr}
	cd ${scriptdir}/setuidgid/ && \
	    ./test_setuidgid "${username_groupname}" 2>> ${test_stderr}
	cmd_exitcode=$?

	if [ ${cmd_exitcode} -eq "$EX_NOPERM" ]; then
		# Skip this check, since we can only really test setuidgid
		# as root (or otherwise have permission to change the username
		# and group list).
		echo "-1" > ${c_exitfile}
	elif [ ${cmd_exitcode} -eq ${pass_exitcode} ]; then
		# We match the expect output.
		echo "0" > ${c_exitfile}
	else
		# Fail
		echo ${cmd_exitcode} >> ${test_stderr}
		echo "1" > ${c_exitfile}
	fi
}

### Actual command
scenario_cmd() {
	rm -f ${test_stderr}

	# These should all fail.  (Hopefully nobody actually has
	# "fake_username" or "fake_groupname" on their systems!)
	test_setuidgid_username_groupname "foo:" 1
	test_setuidgid_username_groupname ":bar" 1
	test_setuidgid_username_groupname "fake_username" 1
	test_setuidgid_username_groupname "fake_username:fake_groupname" 1

	# Try as self.
	test_setuidgid_username_groupname "$(id -u -n):$(id -g -n)" 0

	# Try as nobody.
	test_setuidgid_username_groupname "nobody" 0
	test_setuidgid_username_groupname "nobody:$(id -gn nobody)" 0
}
