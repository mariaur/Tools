git config --global diff.tool bc4
git config --global difftool.prompt false
git config --global difftool.bc4.cmd "\"c:/program files/beyond compare 4/bcomp.exe\" $(cygpath -w $LOCAL) $REMOTE"
git config --global merge.tool bc4
git config --global mergetool.prompt false
git config --global mergetool.bc4.cmd "\"c:/program files/beyond compare 4/bcomp.exe\" $LOCAL $REMOTE $BASE $MERGED"