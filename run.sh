#!/usr/bin/env bash

lockfile=.run.lock

# exit wrapper, first parameter is exit code
function finish {
    rm ${lockfile}
    # if failed reset assets folder to HEAD
    if [ "$1" -eq "1" ]; then
        git checkout HEAD -- assets/
    fi
    exit $1
}

function redoutput {
    echo -e '\033[0;31m'$1'\033[0m'
}

function error {
    redoutput $1
    echo $(date +"%r %d %h %y") ":" $1 | tee -a error.log
}

if [ $(whoami) == "root" ]; then
    echo "Please don't run this as root"
    finish 1
fi

if [ -f "$lockfile" ] && kill -0 "$(cat ${lockfile})" 2>/dev/null; then
    echo Still running
    finish 1
fi

echo $$ > ${lockfile}

node run.js

if [ "$?" -eq "1" ];
then
  redoutput "NODE SCRIPT PRODUCED ERRORS, CHECK error.log"
  finish 1
fi

echo

git add -A

# only commit and push if changes are found
if [[ $(git status --porcelain) ]]; then
    git commit -m "$(git status --porcelain | sed ':a;N;$!ba;s/\n/, /g')"
    git push
else
    echo "No changes found"
fi

finish 0