#! /bin/bash
# TODO convert into generic utility that creates export statements for an input list of functions
ghead -c-2 $1 && echo "" && cat $2 && echo ")"
