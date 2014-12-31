#!/usr/bin/env python

# Import modules
# import os
from subprocess import check_output
from datetime import datetime, date
# from subprocess import call

# Set Commitfie variables
COMMITFIE_ROOT = "$HOME/.git-commitpics"
COMMITFIE_IMG_DIR = "$COMMITFIE_ROOT/assets/img/commit"
COMMITFIE_THUMB_DIR = "$COMMITFIE_ROOT/assets/img/commit/thumbs"
COMMITFIE_POST_DIR = "$COMMITFIE_ROOT/_posts/commit"

# Set Github and local git variables
GITHUB_DOMAIN = "https://github.com"
GIT_LOCAL_USER_NAME = check_output(["git", "config", "user.name"])
GIT_LOCAL_USER_EMAIL = check_output(["git", "config", "user.email"])

# Set time of day
NOW = date.today()
CURRENT_HOUR = datetime.now().hour
TIME_OF_DAY = ""

if CURRENT_HOUR < 5:
    TIME_OF_DAY = "deep night"
elif CURRENT_HOUR < 8:
    TIME_OF_DAY = "early morning"
elif CURRENT_HOUR < 11:
    TIME_OF_DAY = "morning"
elif CURRENT_HOUR < 13:
    TIME_OF_DAY = "midday"
elif CURRENT_HOUR < 16:
    TIME_OF_DAY = "afternoon"
elif CURRENT_HOUR < 18:
    TIME_OF_DAY = "late afternoon"
elif CURRENT_HOUR < 21:
    TIME_OF_DAY = "evening"
elif CURRENT_HOUR <= 23:
    TIME_OF_DAY = "late evening"

# Get last commit info
COMMIT_HASH = check_output(["git", "log", "-1", "--pretty=%h"])

# COMMIT_HASH=$(git log -1 --pretty="%h")
# COMMIT_HASH_LONG=$(git log -1 --pretty="%H")
# COMMIT_AUTHOR_NAME=$(git log -1 --pretty="%an")
# COMMIT_AUTHOR_EMAIL=$(git log -1 --pretty="%ae")
# COMMIT_DATE=$(git log -1 --pretty="%ad")
# COMMIT_MESSAGE=$(git log -1 --pretty="%s")
# COMMIT_REPOSITORY_URL=$(git config --get remote.origin.url)
# # todo - create name from pwd if not url is set
# COMMIT_REPOSITORY=$(echo $COMMIT_REPOSITORY_URL | sed "s/$GITHUB_DOMAIN\///g")
# COMMIT_BRANCH=$(git symbolic-ref --short HEAD)
# COMMIT_PICTURE="$NOW-${PWD##*/}-$COMMIT_HASH"
# COMMIT_POST="$COMMIT_PICTURE.markdown"
#
# # Set picture and post names
# COMMIT_PICTURE = NOW + "-" + PWD + "-" + COMMIT_HASH
# COMMIT_POST="$COMMIT_PICTURE.markdown"

# Take the picture and create the thumbnail

# Geotag the commit

# Write the post content
