@echo off
start remedybg bin\fish.rdbg
start gvim source/main.jai
start wt.exe -d %~dp0
