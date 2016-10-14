git add -A && git stash && git clean -fxd && git pull && git stash pop && call init.cmd && msbuild /v:minimal /fl /flp:verbosity=normal /m
