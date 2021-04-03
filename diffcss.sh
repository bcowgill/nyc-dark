#!/bin/bash
# Diff the CSS from node_modules with the ones here.
if which vdiff.sh; then
	if [ -z "$1" ]; then
		DIFF=vdiff.sh
	else
		# diffcss.sh --reverse
		DIFF=rvdiff.sh
	fi
else
	DIFF=$VDIFF
fi

prettydiff.sh ./node_modules/istanbul-reports/lib/html/assets/vendor/prettify.css  prettify.source.css
$DIFF ./node_modules/istanbul-reports/lib/html/assets/base.css base.css
$DIFF ./node_modules/istanbul-reports/lib/html/assets/vendor/prettify.css prettify.css
$DIFF ./node_modules/istanbul-reports/lib/html/assets/vendor/prettify.js prettify.js
