call "%~dp0\StashClean.cmd" & call "%~dp0\..\nuget\nuget.exe" restore & msbuild /v:minimal /fl /flp:verbosity=normal /m
