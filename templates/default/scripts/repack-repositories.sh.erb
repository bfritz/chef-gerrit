#!/bin/sh

# Git repositories benefit from a period process which combines
# together existing pack files and produces a new, smaller pack
# file containing the repository content.
# On the desktop this is run automatically every so often.
# Gerrit Code Review however does not automatically repack its managed
# repositories.
# 
# review.source.android.com runs the following script periodically,
# depending on how many changes the site is getting, but on average
# about once every two weeks:
# http://groups.google.com/group/repo-discuss/web/repository-repacking

BASE=<%= node.gerrit.install_dir %>/git
cd $BASE
for REPO in $(find . -type d -name \*.git | sed 's,^./,,')
do
  REPODIR=$BASE/$REPO

  git --git-dir=$REPODIR config repack.usedeltabaseoffset true
  git --git-dir=$REPODIR config pack.compression 9
  git --git-dir=$REPODIR config pack.indexversion 2

  git --git-dir=$REPODIR config gc.autopacklimit 4
  git --git-dir=$REPODIR config gc.packrefs true
  git --git-dir=$REPODIR config gc.reflogexpire never
  git --git-dir=$REPODIR config gc.reflogexpireunreachable never

  git --git-dir=$REPODIR config pack.threads  6
  git --git-dir=$REPODIR config pack.window 250
  git --git-dir=$REPODIR config pack.depth   50

  rm -rf $REPODIR/logs/refs/changes 2> /dev/null

  git --git-dir=$REPODIR gc --auto --prune || break

  (find $REPODIR/refs/changes -type d | xargs rmdir;
   find $REPODIR/refs/changes -type d | xargs rmdir
  ) 2> /dev/null
done
