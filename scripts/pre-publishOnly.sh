#!/bin/bash
# Do not run directly, npm will invoke this script at the right time (twice).
# pre-publishOnly script, check the repo and package version vs published version.
# this script runs twice during an npm publish so we use a LOCK directory to prevent double actions.
# https://docs.npmjs.com/cli/v7/commands/npm-version

CMD=pre-publishOnly.sh
PKG=$NPMPKG
NPM=pnpm
LOCK=npm-prepublishOnlyLOCKED

# terminate on first error
set -e

# turn on trace of currently running command if you need it
#set -x

if mkdir $LOCK ; then
	echo $CMD handler semaphore dir $LOCK created.
	rmdir $LOCK
else
	echo $CMD handler semaphore dir $LOCK exists skip actions this time.
	exit
fi

echo ""
echo Step 1: Git checks.
# Git checks normally done by npm, but we are running with --no-git-checks due to our old version of git.
repo-check.sh
BRANCH=`git symbolic-ref --short HEAD`
if [ "$BRANCH" != 'main' ]; then
	echo "You're on branch \"$BRANCH\" but your \"publish-branch\" is set to \"master|main\". Do you want to continue? \(y/N\) "
	read continue
	case $continue in
		y)		echo ok publishing from branch $BRANCH;;
		Y)		echo ok publishing from branch $BRANCH;;
		*)		exit 70;;
	esac
fi
if [ "`git rev-list --count --left-only @{u}...HEAD`" != '0' ]; then
	echo NOT OK you are publishing from before the HEAD commit or without having set an upstream.
	exit 71
fi

echo ""
echo Step 2: Version number build checks.
REL_VER=`packagever.sh`
if [ -z "$REL_VER" ]; then
	echo NOT OK getting version number
	exit 72
fi

COUNT=1
if [ "`grep $REL_VER prettify.js | wc -l`" == "$COUNT" ] ; then
	echo ok "prettify.js" version updated
else
	echo NOT OK - "prettify.js" does not contain $COUNT release version $REL_VER numbers
	exit 73
fi

COUNT=1
if [ "`grep $REL_VER prettify.css | wc -l`" == "$COUNT" ] ; then
	echo ok "prettify.css" version updated
else
	echo NOT OK - "prettify.css" does not contain $COUNT release version $REL_VER numbers
	exit 74
fi

COUNT=1
if [ "`grep $REL_VER base.css | wc -l`" == "$COUNT" ] ; then
	echo ok "base.css" version updated
else
	echo NOT OK - "base.css" does not contain $COUNT release version $REL_VER numbers
	exit 74
fi

if grep "\* $REL_VER" README.md ; then
	echo ok README.md
else
	echo NOT OK - README.md does not contain a version $REL_VER release note
	exit 75
fi

# Error here is ok if we have never been published.
set +e
PUB_VER=`$NPM view $PKG version`
set -e
if [ -z "$PUB_VER" ]; then
	echo WARNING getting published version number, ok if this is first release.
fi

echo VERS: /$REL_VER/$PUB_VER/

if [ "$REL_VER" == "$PUB_VER" ]; then
	echo NOT OK current version has already been published to the npm registry.
	exit 78
fi

echo ""
echo Step 3: Prepare for package install test.
rm -rf package || echo "ok no package/ directory exists"

#echo ""
#echo Step 4: Disable postinstall script for husky.
# For husky we need to disable the postinstall action while publishing.
#pinst --disable
mkdir $LOCK

# after this, the package.json prepublishOnly script will run once again.
# it is called by npm once printing the directory name, then once printing no directory name.
# so the pinst --disable will make a change to package.json to prevent postinstall action.
# after that the npm pack command is run to create the .tgz archive and it is published.
# Then the publish script runs and then the postpublish runs twice
# first without the directory name, then with the directory name.
