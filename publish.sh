#!/bin/bash

cp -r public/* ../cheatex.github.io/

pushd ../cheatex.github.io/

git add *
git commit -am "site update"
git push origin master

popd
