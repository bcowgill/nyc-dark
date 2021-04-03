#!/bin/bash
echo VERSION NUMBERS:
echo "   npm published: `npm view $NPMPKG version`"
echo "   local: `packagever.sh`"
egrep 'version.*[:=].*[0-9]+\.[0-9]+\.[0-9]' node_modules/mocha/package.json $VERFILES \
| perl -pne '$_ = qq{   $_}'
