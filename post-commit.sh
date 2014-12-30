#!/bin/sh

# Run the post-commit script in a separate process to avoid hanging
nohup $HOME/.git-commitpics/script/commitpics.sh &>/dev/null &
