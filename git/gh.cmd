@echo off 
if {%1} NEQ {} (
    git log --pretty="format:%%C(auto)%%h%%Creset%%C(auto)%%d%%Creset %%s %%C(cyan)[%%ce]%%Creset %%Cgreen(%%ar)%%Creset" --graph %*
) else (
    git log --pretty="format:%%C(auto)%%h%%Creset%%C(auto)%%d%%Creset %%s %%C(cyan)[%%ce]%%Creset %%Cgreen(%%ar)%%Creset" --graph .
)
