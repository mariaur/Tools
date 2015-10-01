@echo off

for /f "tokens=*" %%p in ('git rev-parse --show-toplevel') do set ___GR="%%p"

if "%___GR%" == "" (
    exit /B 1
) else (
    pushd %___GR%
)

