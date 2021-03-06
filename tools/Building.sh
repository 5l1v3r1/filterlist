#!/bin/bash

# Homepage: https://github.com/bogachenko/filterlist/
# Description: A slightly ugly script that collects filters. There are probably better ways to do this, but for now my little assistant is doing his job.
# License: Unlicense (see License - https://raw.githubusercontent.com/bogachenko/filterlist/master/LICENSE.md).

TEMP='../src/tmp/'
SRC='../src/'
DATE=$(date '+%Y-%m-%d %H:%M:%S')
VERSION=$(date '+%Y%m%d%H%M%S')

if [ -e "$SRC" ]
then
echo 'In order to collect all the filters in one list, we need a temporary folders.'
if [ ! -d $TEMP ]
then
	echo 'Creating temporary folder...'
	mkdir $TEMP
	sleep .5
	echo 'Folder created!'
else
echo 'Directory already exists'  
fi
python FOP.py $SRC
echo 'Updating the filter lists...'
git pull
git status
git commit -a -m 'Update files'
cp $SRC/other.txt $TEMP
cp $SRC/servers.txt $TEMP
cp $SRC/blacklist.txt $TEMP
cp $SRC/whitelist.txt $TEMP
sort --output=$TEMP/hosts $TEMP/blacklist.txt $TEMP/whitelist.txt
sort --output=$TEMP/filterlist.txt $TEMP/other.txt $TEMP/servers.txt
echo 'Creating a header for the list...'
LINES=$(grep -c '' $TEMP/filterlist.txt)
cat > $TEMP/header1.txt <<EOF
! Title: bogachenko's Filter List
! Description: Yet another anti-bullshit filter list.
! Last modified: ${DATE}
! Version: ${VERSION}
! Expires: 3 hours
! Number of filters: ${LINES}
! RAW: https://raw.githubusercontent.com/bogachenko/filterlist/master/filterlist.txt
! Homepage: https://github.com/bogachenko/filterlist/
! Licence: https://raw.githubusercontent.com/bogachenko/filterlist/master/LICENSE.md

EOF
cat $TEMP/header1.txt $TEMP/filterlist.txt > ../filterlist.txt

echo 'Creating a header for the DNS list...'
LINES=$(grep -c '' $TEMP/hosts)
cat > $TEMP/header2.txt <<EOF
# Title: bogachenko's DNS Filter
# Description: Yet another anti-bullshit filter list.
# Last modified: ${DATE}
# Version: ${VERSION}
# Expires: 3 hours
# Number of filters: ${LINES}
# RAW: https://raw.githubusercontent.com/bogachenko/filterlist/master/hosts
# Homepage: https://github.com/bogachenko/filterlist/
# Licence: https://raw.githubusercontent.com/bogachenko/filterlist/master/LICENSE.md

# README: Simplified specifically to be better compatible with DNS-level ad blocking.

EOF
cat $TEMP/header2.txt $TEMP/hosts > ../hosts

echo 'Delete temporary files...'
rm -rf $TEMP
echo 'Deletion complete!'
echo 'Do you want to send modified files to Git (y/N)?'
select yn in "Yes" "No"; do
	case $yn in
		Yes )
		git pull
		git status
		git commit -a -m 'Auto update files'
		git push origin master;
		break
		;;
		No )
		exit
		;;
    esac
done
echo 'Upload finished'
sleep 1
else
        echo "There is no SRC root directory, check your data."
		read -n 1 -s -r -p 'Press any key to exit.'
fi