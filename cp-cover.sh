#!/bin/bash
DIR=${1:-coverage}
CHANGED=1
FROM=./node_modules/nyc-dark/

while /bin/true; do
	if [ $CHANGED ]; then
		cp $FROM/*.css $DIR/
	fi
	sleep 1
	diff $FROM/base.css $DIR/base.css > /dev/null
	CHANGED=$?
done
