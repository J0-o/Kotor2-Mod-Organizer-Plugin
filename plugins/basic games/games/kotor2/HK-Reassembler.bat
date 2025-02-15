
@echo off
setlocal enabledelayedexpansion
color 03

call hkdata\paths.bat

call hkdata\reqcheck.bat

call hkdata\patcherdl.bat

call hkdata\filescan.bat

call hkdata\multipatch.bat

call hkdata\cleaner.bat