git config --system alias.dt "difftool -d"
git config --system alias.dts "difftool -d --staged"

git config --system core.pager "less -+S"
git config --system core.editor gvim.exe
git config --system diff.tool windiff
git config --system difftool.windiff.cmd "windiff.exe \"$LOCAL\" \"$REMOTE\""
git config --system difftool.prompt false
