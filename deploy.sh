#!/bin/bash
# A modification of Dean Clatworthy's deploy script as found here: https://github.com/deanc/wordpress-plugin-git-svn
# The difference is that this script lives in the plugin's git repo & doesn't require an existing SVN repo.

# main config
PLUGINSLUG="wapuuvatar"
CURRENTDIR=`pwd`
MAINFILE="wapuuvatar.php" # this should be the name of your main php file in the wordpress plugin

# git config
GITPATH="$CURRENTDIR" # this file should be in the base of your git repository

# svn config
SVNPATH="/tmp/$PLUGINSLUG" # path to a temp SVN repo. No trailing slash required and don't add trunk.
SVNURL="https://plugins.svn.wordpress.org/wapuuvatar" # Remote SVN repo on wordpress.org, with no trailing slash
SVNUSER="leewillis77" # your svn username

# Let's begin...
echo ".........................................."
echo
echo "Preparing to deploy wordpress plugin"
echo
echo ".........................................."
echo

# Check version in readme.txt is the same as plugin file after translating both to unix line breaks to work around grep's failure to identify mac line breaks
NEWVERSION1=`grep "^Stable tag:" $GITPATH/readme.txt | awk -F' ' '{print $NF}'`
echo "readme.txt version: $NEWVERSION1"
NEWVERSION2=`grep "^Version:" $GITPATH/$MAINFILE | awk -F' ' '{print $NF}'`
echo "$MAINFILE version: $NEWVERSION2"

if [ "$NEWVERSION1" != "$NEWVERSION2" ]; then echo "Version in readme.txt & $MAINFILE don't match. Exiting...."; exit 1; fi

echo "Versions match in readme.txt and $MAINFILE. Let's proceed..."

if git show-ref --tags --quiet --verify -- "refs/tags/$NEWVERSION1"
	then
		echo "Version $NEWVERSION1 already exists as git tag. Assuming everything pushed.";
	else
		echo "Git version does not exist. Let's proceed..."

		cd $GITPATH
		echo -e "Enter a commit message for this new version: \c"
		read COMMITMSG
		git commit -am "$COMMITMSG"
		
		echo "Tagging new version in git"
		git tag -a "$NEWVERSION1" -m "Tagging version $NEWVERSION1"
		
		echo "Pushing latest commit to origin, with tags"
		git push origin master
		git push origin master --tags
fi

echo
echo "Creating local copy of SVN repo ..."
svn co $SVNURL $SVNPATH || exit 255

echo "Clearing out generated image path in SVN checkout"
rm $SVNPATH/trunk/dist/*.png || exit 254

echo "Removing no longer needed files"
rm $SVNPATH/trunk/package.json $SVNPATH/trunk/package-lock.json

echo "Exporting the HEAD of master from git to the trunk of SVN"
git checkout-index -a -f --prefix=$SVNPATH/trunk/ || exit 253

echo "Removing src images"
rm $SVNPATH/trunk/src/*

echo "Ignoring github specific files, source images and deployment script"
svn propset svn:ignore "deploy.sh
README.md
.git
.gitignore
build-avatars.sh" "$SVNPATH/trunk/"

echo "Changing directory to SVN and committing to trunk"
cd $SVNPATH/trunk/

# Add all new files that are not set to be ignored
svn status | grep -v "^.[ \t]*\..*" | grep "^?" | awk '{print $2}' | xargs svn add
# Remove all files that are now missing
svn status | grep -v "^.[ \t]*\..*" | grep "^\!" | awk '{print $2}' | xargs svn delete

svn commit --username=$SVNUSER -m "$COMMITMSG"

echo "Creating new SVN tag & committing it"
cd $SVNPATH
svn copy trunk/ tags/$NEWVERSION1/
cd $SVNPATH/tags/$NEWVERSION1
svn commit --username=$SVNUSER -m "Tagging version $NEWVERSION1"

echo "Removing temporary directory $SVNPATH"
rm -fr $SVNPATH/

echo "*** FIN ***"
