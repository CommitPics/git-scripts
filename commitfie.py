#!/usr/bin/env python

# Import modules
import os
import json
import subprocess
from datetime import datetime, date

# Global variables
HOME = os.path.expanduser("~")
CWD_PATH = os.getcwd()
CWD = os.path.basename(CWD_PATH)

# Function Definitions
def commandCall(cmd):
    process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = process.communicate()
    if (process.returncode == 0):
        # print out
        return out
    else:
        # err = err.replace('\n', ' ').replace('\r', '')
        return "n/a"

# Set Commitfie variables
COMMITFIE_ROOT = HOME+"/.git-commitfie"
COMMITFIE_IMG_DIR = COMMITFIE_ROOT+"/assets/img/commit"
COMMITFIE_THUMB_DIR = COMMITFIE_ROOT+"/assets/img/commit/thumbs"
COMMITFIE_POST_DIR = COMMITFIE_ROOT+"/_posts/commit"

# Set Github and local git variables
GITHUB_DOMAIN = "https://github.com"
GIT_LOCAL_USER_NAME = commandCall("git config --global --get user.name").replace('\n', '').replace('\r', '')
GIT_LOCAL_USER_EMAIL = commandCall("git config --global --get user.email").replace('\n', ' ').replace('\r', '')

# Set time of day
today = date.today()
NOW = today.strftime("%Y-%m-%d")
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
COMMIT_HASH = commandCall("git log -1 --pretty=format:%h")
COMMIT_HASH_LONG = commandCall("git log -1 --pretty=format:%H")
COMMIT_DATE = commandCall("git log -1 --pretty=format:%ad")
COMMIT_DATE_SHORT = commandCall("git log -1 --pretty=format:%ad --date=short")
COMMIT_MESSAGE = commandCall("git log -1 --pretty=format:%s")
COMMIT_BRANCH = commandCall("git symbolic-ref --short HEAD")
COMMIT_REPOSITORY_ORIGIN = commandCall("git config --get remote.origin.url")
COMMIT_REPOSITORY_NAME = COMMIT_REPOSITORY_ORIGIN.replace(GITHUB_DOMAIN + '/', '')

# Set picture and post names
COMMIT_PICTURE = COMMIT_DATE_SHORT + "-" + CWD + "-" + COMMIT_HASH + "-" + GIT_LOCAL_USER_NAME
COMMIT_POST = COMMIT_PICTURE + ".markdown"

# Take the picture and create the thumbnail
IMAGESNAP_CMD = "imagesnap " + COMMITFIE_IMG_DIR+"/"+COMMIT_PICTURE+".jpg -q -w 1"
NULL = commandCall(IMAGESNAP_CMD)
THUMBNAIL_CMD = "convert " + COMMITFIE_IMG_DIR+"/"+COMMIT_PICTURE+".jpg -thumbnail 70x70^ -gravity center -extent 70x70 "+COMMITFIE_THUMB_DIR+"/"+COMMIT_PICTURE+".jpg"
NULL = commandCall(THUMBNAIL_CMD)

# Geotag the commit
LAT_LONG = commandCall("whereami")
GOOGLE_MAPS_CMD = "curl curl http://maps.googleapis.com/maps/api/geocode/json\?latlng\="+LAT_LONG
GEO_JSON = commandCall(GOOGLE_MAPS_CMD)
if GEO_JSON != "n/a":
    results = json.loads(GEO_JSON)['results'][0]['address_components']
    for address_component in results:
        if address_component['types'] == ['locality', 'political']:
            COMMIT_TOWN = address_component['long_name']
        if address_component['types'] == ['country', 'political']:
            COMMIT_COUNTRY = address_component['long_name']
else:
    COMMIT_TOWN = "@"
    COMMIT_COUNTRY = "@"

print COMMIT_TOWN
print COMMIT_COUNTRY

# # Create post
# if [ -f "$COMMIT_POST_DIR/$COMMIT_POST" ] ; then
# 	rm $COMMIT_POST_DIR/$COMMIT_POST
# fi
# touch $COMMIT_POST_DIR/$COMMIT_POST

# Write the post content
