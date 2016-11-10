#!/usr/bin/env bash

lockfile=.run.lock

if [ -f "$lockfile" ] && kill -0 "$(cat $lockfile)" 2>/dev/null; then
	echo Still running
	exit 1
fi

echo $$ > $lockfile

git rm -rf assets/*

# get array of relative dirs and urls
result=($(node getassetlist.js | sed 's/\"//g' | sed 's/,/ /g' | tr -d '[],'))

len=$(expr ${#result[@]} / 2)
files=""

echo

for i in $(seq 0 $(expr ${len} - 1))
do
    mkdir -p assets/${result[$i]%/*}
    wget -O assets/${result[$i]} ${result[$(expr ${i} + ${len})]} -q --show-progress
    files+=${PWD}/assets/${result[$i]}" "
done

echo
node beautify.js ${files:0:${#files}-1}

git add -A

if [[ $(git status --porcelain) ]]; then
    git commit -m "$(git status --porcelain | sed ':a;N;$!ba;s/\n/, /g')"
    git push
else
    echo No changes found
fi

rm $lockfile