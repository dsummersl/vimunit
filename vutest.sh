#!/bin/sh

# (c) 2012, Dane Summers <dsummers@pinedesk.biz>
# 
# This work is licensed under the Creative Commons Attribution 3.0 Unported
# License. To view a copy of this license, visit
# http://creativecommons.org/licenses/by/3.0/.


set -u
# don't want to fail on a test failure, we'll handle it in the script and pass it on.
# set -e

if [[ $# -lt 1 ]]; then
	echo "vutest.sh <script.vim>"
	echo ""
	echo "Run vimUnit tests and return results to the command line."
	echo ""
	echo "Example:"
	echo "  vutest.sh ~/.vim/bundle/vimunit/plugin/vim_unit.vim"
	exit 1
fi

tmpfile=`mktemp -t log.txt`

vim -nc "so % | call VURunAllTests(true,'$tmpfile')" $1
returncode=$?
cat $tmpfile

exit $returncode
