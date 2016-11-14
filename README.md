# WAT (Website Asset Tracker)

JS/CSS change tracker written in bash and js (node)

Downloads and prettifies javascript, css files from predefined URLs; commits them to git
Useful for troubleshooting scraping issues - if you use CSS selectors or execute JS with a headless browser using this you can examine why your selectors/scripts were broken or just for tracking your favorite bands website :^)

## How to use
1.	Clone this repo in a new repo or just fork it and set up a [deploy key](https://developer.github.com/guides/managing-deploy-keys/#deploy-keys) for your repo so the script can push code without authentication
2.  Add an upstream to this repo `git remote add upstream https://github.com/darksworm/website-asset-tracker.git` so you can fetch ~~changes~~ *bugfixes* from this repo [how to use](https://help.github.com/articles/syncing-a-fork/)
3.  npm install
4.  set up urls.json (example provided)
5.  set up cron or any other job scheduler however you want (for run.sh)
6.  profit

## Prerequisites
1.  node 4.6.1
2.  wget 1.16 or newer

## Good to know
*   run.sh takes no parameters
*   errors get written to error.log in the same directory (this file won't be commited)
*   I've implemented proper exit codes for run.sh so if you want to run another script if something goes wrong just do `bash run.sh || do-something`
*   run.sh will exit with code 1 if:
    1.  you run it as root
    2.  wget failed for at least one of the provided urls
    3.  beautifying at least one of the files failed