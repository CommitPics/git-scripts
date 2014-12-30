#!/bin/zsh

# Set global variables & path
# COMMIT_PICS_PATH=$(realpath $PWD)
COMMIT_PICS_PATH="$HOME/.git-commitpics"
COMMIT_IMG_DIR="$COMMIT_PICS_PATH/assets/img/commit"
COMMIT_THUMB_DIR="$COMMIT_PICS_PATH/assets/img/commit/thumbs"
COMMIT_POST_DIR="$COMMIT_PICS_PATH/_posts/commit"
COLORATION_SCRIPT="$COMMIT_PICS_PATH/script/coloration"
GITHUB_DOMAIN="https://github.com"

# Set time of day
NOW=$(date +"%F")

if [ $(date +"%k") -lt 5 ] ; then
	TIME_OF_DAY="deep night"
elif [ $(date +"%k") -lt 8 ] ; then
	TIME_OF_DAY="early morning"
elif [ $(date +"%k") -lt 11 ] ; then
	TIME_OF_DAY="morning"
elif [ $(date +"%k") -lt 13 ] ; then
	TIME_OF_DAY="midday"
elif [ $(date +"%k") -lt 16 ] ; then
	TIME_OF_DAY="afternoon"
elif [ $(date +"%k") -lt 18 ] ; then
	TIME_OF_DAY="late afternoon"
elif [ $(date +"%k") -lt 21 ] ; then
	TIME_OF_DAY="evening"
elif [ $(date +"%k") -le 23 ] ; then
	TIME_OF_DAY="late evening"
fi

# Git variables
GIT_LOCAL_USER_NAME=$(git config user.name)
GIT_LOCAL_USER_EMAIL=$(git config user.email)

# Get commit info
COMMIT_HASH=$(git log -1 --pretty="%h")
COMMIT_HASH_LONG=$(git log -1 --pretty="%H")
COMMIT_AUTHOR_NAME=$(git log -1 --pretty="%an")
COMMIT_AUTHOR_EMAIL=$(git log -1 --pretty="%ae")
COMMIT_DATE=$(git log -1 --pretty="%ad")
COMMIT_MESSAGE=$(git log -1 --pretty="%s")
COMMIT_REPOSITORY_URL=$(git config --get remote.origin.url)
# todo - create name from pwd if not url is set
COMMIT_REPOSITORY=$(echo $COMMIT_REPOSITORY_URL | sed "s/$GITHUB_DOMAIN\///g")
COMMIT_BRANCH=$(git symbolic-ref --short HEAD)
COMMIT_PICTURE="$NOW-${PWD##*/}-$COMMIT_HASH"
COMMIT_POST="$COMMIT_PICTURE.markdown"

# Get geotag
IP_ADDRESS=$(dig +short myip.opendns.com @resolver1.opendns.com)
GEOTAG_RAW=$(curl --max-time 25 -s --get http://freegeoip.net/json/$IP_ADDRESS)
LATITUDE=$(echo $GEOTAG_RAW | sed -e "s/^.*\"latitude\":\(.*\)\,\"longitude.*/\1/")
LONGITUDE=$(echo $GEOTAG_RAW | sed -e "s/^.*\"longitude\":\(.*\)\,\"metro.*/\1/")
COUNTRY=$(echo $GEOTAG_RAW | sed -e "s/^.*\"country_name\":\"\(.*\)\"\,\"region_code.*/\1/")
CITY=$(echo $GEOTAG_RAW | sed -e "s/^.*\"city\":\"\(.*\)\"\,\"zip.*/\1/")

# Take picture - wait for 1 second to allow better lightning
imagesnap $COMMIT_IMG_DIR/$COMMIT_PICTURE.jpg -q -w 1

# Create thumnail
convert $COMMIT_IMG_DIR/$COMMIT_PICTURE.jpg -thumbnail 70x70^ -gravity center -extent 70x70  $COMMIT_THUMB_DIR/$COMMIT_PICTURE.jpg

# Colorize picture based on number of seconds in the current minute
# HUE=$(($(date +%S)*359/59))
# eval "$COLORATION_SCRIPT" -h $HUE -s 75 -l 0 $COMMIT_IMG_DIR/$COMMIT_PICTURE.jpg $COMMIT_IMG_DIR/$COMMIT_PICTURE.jpg

# Create post
if [ -f "$COMMIT_POST_DIR/$COMMIT_POST" ] ; then
	rm $COMMIT_POST_DIR/$COMMIT_POST
fi
touch $COMMIT_POST_DIR/$COMMIT_POST

# Write content to post
echo \
"---
layout: commit

title:  \"$COMMIT_HASH\"
date:   $(date +"%c")

author: $COMMIT_AUTHOR_NAME
email:  $COMMIT_AUTHOR_EMAIL

img: $COMMIT_PICTURE.jpg
hash: $COMMIT_HASH_LONG
commitdate: $COMMIT_DATE
message: $COMMIT_MESSAGE
repository: $COMMIT_REPOSITORY
url: $COMMIT_REPOSITORY_URL
branch: $COMMIT_BRANCH

latitude: $(if [[ ! -z $LATITUDE  ]] ; then echo $LATITUDE ; else echo "n/a" ; fi)
longitude: $(if [[ ! -z $LONGITUDE  ]] ; then echo $LONGITUDE ; else echo "n/a" ; fi)
city: $(if [[ ! -z $CITY  ]] ; then echo $CITY ; else echo "n/a" ; fi)
country: $(if [[ ! -z $COUNTRY ]] ; then echo $COUNTRY ; else echo "n/a" ; fi)

categories:
- $COMMIT_AUTHOR_NAME
- $COMMIT_REPOSITORY
- $TIME_OF_DAY
- $(date +"%A")
- $(date +"%B")
- $(date +"%Y")
- $(if [[ ! -z $CITY ]] ; then echo $CITY ; else echo "n/a" ; fi)
- $(if [[ ! -z $COUNTRY ]] ; then echo $COUNTRY ; else echo "n/a" ; fi)
---

~~~diff
$(git log -1 --stat)
~~~" >> $COMMIT_POST_DIR/$COMMIT_POST

# add all new files and commit
cd $COMMIT_PICS_PATH
git add --all
git commit -am "add new commit pics for $COMMIT_AUTHOR_NAME working on $COMMIT_REPOSITORY - $COMMIT_HASH"
git push origin gh-pages

