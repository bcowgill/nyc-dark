#!/bin/bash
DIR=${1:-coverage}
CHANGED=1
FROM=./node_modules/nyc-dark/

while [ 1 == 1 ]; do
	if [ $CHANGED != 0 ]; then
		echo `date` copy dark stylesheet from $FROM/ to $DIR/
		cp $FROM/*.css $DIR/
	fi
	sleep 1
	diff $FROM/base.css $DIR/base.css > /dev/null
	CHANGED=$?
done
