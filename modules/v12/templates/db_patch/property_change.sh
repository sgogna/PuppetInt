#!/bin/bash

pattern=$1
replacement=$2
propvalue=`sed '/^\#/d' $3 | grep $1 | tail -n 1 | sed 's/^.*=//;s/^[[:space:]]*//;s/[[:space:]]*$//'`
A="`echo | tr '\012' '\001' `"
sed -i -e "s$A$pattern=$propvalue$A$pattern=$replacement$A" $3

