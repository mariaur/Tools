git config --global push.followTags true

git config --global core.pager "less -+S"
git config --global core.editor gvim.exe
git config --global diff.tool windiff
git config --global difftool.windiff.cmd "windiff.exe \"$LOCAL\" \"$REMOTE\""
git config --global difftool.prompt false

git config --global user.name "Kalin Toshev"
git config --global user.email kalint@ntdev.microsoft.com
git config --global branch.autosetuprebase always
git config --global branch.master.rebase true
git config --global fetch.prune true
