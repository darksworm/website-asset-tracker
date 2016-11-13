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
    finish 0
fi

echo $$ > ${lockfile}

# get array of relative dirs and urls
result=($(node getassetlist.js | sed 's/\"//g' | sed 's/,/ /g' | tr -d '[],'))

if [[ -z "${result}" ]]; then
    error "failed to parse urls.json"
    finish 1
fi

# remove old files
rm -rf assets/*

len=$(expr ${#result[@]} / 2)
# parameter for beautify script, all downloaded file absolute paths with spaces as delimiters
files=""
exit_code=0

echo

for i in $(seq 0 $(expr ${len} - 1))
do
    # make file directory recursively
    mkdir -p ${PWD}/assets/${result[$i]%/*}
    # wget file and save to defined directory
    wget -O ${PWD}/assets/${result[$i]} ${result[$(expr ${i} + ${len})]} -q --show-progress --no-cache 2>&1
    if [ "$?" != "0" ]; then
        error "wget failed for url: "${result[$(expr ${i} + ${len})]}
        exit_code=1
    fi
    files+=${PWD}/assets/${result[$i]}" "
done

node beautify.js ${files:0:${#files}-1}
beautify_result=$?

if [[ "$beautify_result" == "1" ]]; then
    echo
    redoutput "Beautify returned errors, check error.log"
    exit_code=1
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

finish ${exit_code}