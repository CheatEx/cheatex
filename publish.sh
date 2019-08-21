#!/bin/bash

cp -r public/* ../cheatex.github.io/
git add * -C ../cheatex.github.io/
git commit -am "site update" -C ../cheatex.github.io/
git push origin master -C ../cheatex.github.io/
