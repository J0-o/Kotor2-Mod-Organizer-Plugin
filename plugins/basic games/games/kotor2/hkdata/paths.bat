set "currentDir=%CD%"

:: Grab MO2 Path
for /f "delims=" %%A in ('cd /d "%~dp0..\..\..\..\.." ^& cd') do set "modir=%%A"
cd !currentDir!

:: ModOrganizer.ini exists
if not exist "!modir!\ModOrganizer.ini" (
	powershell write-host -fore Red [WARNING] ModOrganizer.ini not found. Plugin my not have been installed correctly. Even a droid of my caliber cannot correct your foolish oversight without intervention.
	pause
    exit /b 1
)

echo [REPORT] MO2 Directory found. Stand by for the Extermination of...err, Execution of tasks.

:: Set essential paths
set "mods=!modir!\mods"
set "hkdata=!modir!\plugins\basic_games\games\kotor2\hkdata"
set "modstemp=!hkdata!\mods_temp"
set "overwrite=!modir!\overwrite"
set "modlistinput=!modir!\profiles\Default\modlist.txt"
set "modlist=!hkdata!\modlist.txt"
set "holopatcher=!hkdata!\HoloPatcher.exe"
set "holozip=!hkdata!\HoloPatcher.zip"
set "holourl=https://github.com/NickHugi/PyKotor/releases/download/v1.60-patcher-beta4/HoloPatcher_Windows_x64.zip"
set "filelist=!hkdata!\filelist.txt"
set "filepathlist=!hkdata!\filepathlist.txt"
set "templist=!hkdata!\filelist_temp.txt"

:: Find swkotor2.exe path from ModOrganizer.ini
set "installdir="
for /f "tokens=1,* delims==" %%A in ('findstr /i "swkotor2.exe" "!modir!\ModOrganizer.ini"') do (
    set "installdir=%%B"
)
if not defined installdir (
    powershell write-host -fore Red [DISAPPROVAL] No entry found for swkotor2.exe in ModOrganizer.ini due to your incompetence. Suggest re-checking resources before reassembling.
	pause
    exit /b 1
)

:: Remove "swkotor2.exe" from the path
set "installdir=!installdir:swkotor2.exe=!"

:: Trim any trailing spaces or backslashes
for /f "delims=" %%A in ("!installdir!") do set "installdir=%%A"
set "installdir=!installdir:/=\!"

:: Check if swkotor2.exe exists
if not exist "!installdir!\swkotor2.exe" (
	powershell write-host -fore Red [ERROR] swkotor2.exe not found in "!installdir!". As usual, the blame falls squarely on you, meatbag.
	pause
    exit /b 1
) else (
	echo [REPORT] Install Directory found. Your meddling did not derail the process. Savor this fleeting moment of adequacy.
)

pause