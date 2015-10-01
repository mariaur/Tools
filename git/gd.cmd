@echo off

setlocal

set ___GP=

for /f "tokens=*" %%p in ('git rev-parse --show-prefix') do set ___GP="%%p"

git difftool -d %* -- %___GP%
