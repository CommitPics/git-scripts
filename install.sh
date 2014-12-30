#!/bin/zsh

# Ask if user really wants to install the script
while true; do
	echo "Do you wish to install this program?"
	read yn
	case $yn in
		[Yy]* ) break;;
		[Nn]* ) exit;;
	esac
done

echo "What is your Github username?"
read GITHUB_USERNAME

# Set global variables
GITHUB_DOMAIN="https://github.com"
COMMITFIE_URL="$GITHUB_DOMAIN/Commitfie/git-commitfie"

COMMITFIE_PATH="$HOME/.git-commitfie"
COMMITFIE_SCRIPT_PATH="$COMMITFIE_PATH/script/post-commit.sh"

GIT_TEMPLATES_PATH="$HOME/.git-templates"
GIT_HOOKS_PATH="$GIT_TEMPLATES_PATH/hooks"

# Make sure all the brew dependencies are met
BREW_DEPS=( imagesnap imagemagick whereami )
MISSING_BREW_DEPS=()

echo "\nChecking for \`brew\` dependencies:\n "
for dep in "${BREW_DEPS[@]}"
do
	if ls -al $(brew --prefix)/bin | grep "$dep" &> /dev/null ; then
		echo "Looking for $dep........ OK"
	else
		echo "Looking for $dep........ Error, not found!"
		MISSING_BREW_DEPS+=( $dep )
	fi
done

if [  ${#MISSING_BREW_DEPS[@]} -gt 0 ] ; then
	echo "\nThe following brew dependencies are missing: $MISSING_BREW_DEPS...\nYou must install them to continue the installation process..."
	exit 1
fi

# Create hooks
if [[ ! -d  $GIT_HOOKS_PATH ]] ; then
	echo "\nCreating $GIT_HOOKS_PATH..."
	mkdir -p $GIT_HOOKS_PATH
fi

# Clone commitfie/git-commitfie to ~/.git-commitfie
echo "\nCloning $COMMITFIE_URL to $COMMITFIE_PATH..."
git clone $COMMITFIE_URL $COMMITFIE_PATH || exit 1

# Initialize submodules
cd $COMMITFIE_PATH
echo "\nInitializing submodules in $PWD..."
git submodule init && git submodule update || exit 1

# Remove git files to start brand new
echo "\nRemoving everything related to git and starting anew..."
rm -rf .git .gitmodule
git init
git remote add origin $GITHUB_DOMAIN/$GITHUB_USERNAME/git-commitfie
$(git remote show origin &> /dev/null ) || echo "\nATTENTION! We could not set properly the remote repo, you'll have to do it on your own."

# Symlink the post-commit script
echo "\nSymlinking $COMMITFIE_SCRIPT_PATH to $GIT_HOOKS_PATH/post-commit..."
$(ln -s $COMMITFIE_SCRIPT_PATH $GIT_HOOKS_PATH/post-commit &> /dev/null) || { echo "\nERROR! You already have a post-commit file. Remove it to continue the process." ; exit 1 }

echo \
"\nCongratulation! git-commitfie is now ready to be used!
\`cd\` to a directory you want to track with commit pics and simply run:
	\`git init\`
You should be ready to go!"
