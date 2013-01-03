#!/bin/sh

# (c) 2012, Dane Summers <dsummers@pinedesk.biz>
# 
# This work is licensed under the Creative Commons Attribution 3.0 Unported
# License. To view a copy of this license, visit
# http://creativecommons.org/licenses/by/3.0/.


# TODO add individual test commands (maybe regex matches).

set -u
# don't want to fail on a test failure, we'll handle it in the script and pass it on.
# set -e

help() {
	echo "vutest.sh [-v] <script.vim>"
	echo ""
	echo "Run vimUnit tests and return results to the command line."
	echo ""
  echo "Options:"
  echo " -v Verbose. If set, then messages passed to MsgSink will be displayed when tests fail." 
  echo " -f <output> Save output to a specific file rather than STDOUT."
  echo " -e <VIM>    Specific path to the VIM program."
  echo ""
	echo "Example:"
	echo "  vutest.sh ~/.vim/bundle/vimunit/plugin/vim_unit.vim"
	exit 1
} 

VERBOSE=0
VIM='vim'
FILE=`mktemp -t log.txt`
TOSTDOUT=1
while getopts "vf:e:" opt; do
  case $opt in
    v )
      VERBOSE=1
      ;;
    f )
      FILE=$OPTARG
      TOSTDOUT=0
      ;;
    e )
      VIM=$OPTARG
      ;;
    \?)
      help
      ;;
  esac
done

if [[ $# -lt 1 ]]; then
  help
fi

shift $((OPTIND-1))
$VIM -nc ":so % | let g:vimUnitVerbosity=$VERBOSE | call VURunAllTests(true,'$FILE')" $1
returncode=$?

if [[ $TOSTDOUT -eq 1 ]]; then
  cat $FILE
fi

exit $returncode
