#!/bin/bash

echo "DO NOT USE THIS SCRIPT BEFORE REPO SYNC OR OUTSIDE OF BUILD DIR"
cd build/soong
git remote add soong https://github.com/Tb12345679/android_build_soong
git fetch soong
git cherry-pick c8ba7af59acda55a16835727d1d351b8d58a5ca4
git cherry-pick 53fbaf457ff762fda243ea85f93bf912d94bfac8
git cherry-pick 509895828c96f1f30d8e6af9dfacf7296af73bdb
echo "Done if you still get issues zram might help"

