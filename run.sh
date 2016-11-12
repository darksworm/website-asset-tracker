#!/usr/bin/env bash

lockfile=.run.lock

# exit wrapper, first parameter is exit code
function finish {
    rm ${lockfile}
    # if failed reset assets folder to HEAD
    if [ "$1" -eq "1" ]; then
        git rm -rf assets/*
        git checkout HEAD -- assets/
    fi
    exit $1
}

if [ -f "$lockfile" ] && kill -0 "$(cat ${lockfile})" 2>/dev/null; then
    echo Still running
    finish 0
fi

echo $$ > ${lockfile}

# remove old files
git rm -rf ${PWD}/assets/*

# get array of relative dirs and urls
result=($(node getassetlist.js | sed 's/\"//g' | sed 's/,/ /g' | tr -d '[],'))

len=$(expr ${#result[@]} / 2)
files=""

echo

for i in $(seq 0 $(expr ${len} - 1))
do
    # make file directory recursively
    mkdir -p ${PWD}/assets/${result[$i]%/*}
    # wget file and save to defined directory
    wget -O ${PWD}/assets/${result[$i]} ${result[$(expr ${i} + ${len})]} -q --show-progress --no-cache || { echo wget failed; finish 1; }
    files+=${PWD}/assets/${result[$i]}" "
done

echo

output=$(node beautify.js ${files:0:${#files}-1} 2>&1)

if [[ ! -z $output ]]; then
    echo "beautify.js failed, view error.log for details"
    echo ${output} >> error.log
    finish 1
fi

git add -A

# only commit and push if changes are found
if [[ $(git status --porcelain) ]]; then
    git commit -m "$(git status --porcelain | sed ':a;N;$!ba;s/\n/, /g')"
    git push
else
    echo No changes found
fi

finish 0