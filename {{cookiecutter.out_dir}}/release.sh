#!/usr/bin/env bash
set -ex
version=${version:-$1}
force=${force-}
remote=${remote:-origin}
remotebranch=${remotebranch:-$(git rev-parse --abbrev-ref --symbolic-full-name @{u}|sed -re "s/.*\///g")}
gitargs=""
if [[ -n $force ]];then
    gitargs="--force"
fi
if [[ -z $version ]];then
	echo no version
	exit 1
fi
sed -i -re "s/version = \".*\"/version = \"$version\"/g" setup.py
git commit -m "Release: $version" setup.py || true
git tag -d $version || true
git tag $version
git push $gitargs $remote refs/tags/$version $remotebranch
# vim:set et sts=4 ts=4 tw=80:
