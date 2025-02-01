@echo off
setlocal enabledelayedexpansion

set "currentDir=%CD%"

:: Grab MO2 Path
for /f "delims=" %%A in ('cd /d "%~dp0..\..\..\.." ^& cd') do set "modir=%%A"
cd !currentDir!

:: ModOrganizer.ini exists
if not exist "!modir!\ModOrganizer.ini" (
    echo ERROR: ModOrganizer.ini not found.
    pause
    exit /b 1
)
echo Mod Organizer Directory: !modir!

:: Set essential paths
set "modsDir=!modir!\mods"
set "patchDir=!modir!\plugins\basic_games\games\kotor2\patchfolder"
set "overwriteDir=!modir!\overwrite"
set "modlistinput=!modir!\profiles\Default\modlist.txt"
set "modlist=modlist.txt"
set "holoPatcher=!patchDir!\HoloPatcher.exe"
set "holoZip=!patchDir!\HoloPatcher.zip"
set "holoUrl=https://github.com/NickHugi/PyKotor/releases/download/v1.60-patcher-beta4/HoloPatcher_Windows_x64.zip"
set "filelist=filelist.txt"
set "tempfile=temp_filelist.txt"

:: Counters
set "patchCount=0"
set "errorCount=0"

:: Find swkotor2.exe path from ModOrganizer.ini
set "installdir="
for /f "tokens=1,* delims==" %%A in ('findstr /i "swkotor2.exe" "!modir!\ModOrganizer.ini"') do (
    set "installdir=%%B"
)
if not defined installdir (
    echo ERROR: No entry found for swkotor2.exe in ModOrganizer.ini.
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
    echo ERROR: swkotor2.exe not found in "!installdir!".
    pause
    exit /b 1
) else (
	echo Install Directory: !installdir!
)

:: Check if patch folder exists
if not exist "!patchDir!" (
    echo Creating patch directory: "!patchDir!"
    mkdir "!patchDir!"
) else (
	echo Patch Directory: !patchDir!
)

:: check if HoloPatcher.exe exists, prompt for download
if not exist "!holoPatcher!" (
    echo ERROR: HoloPatcher.exe not found in "!patchDir!".

    choice /C YN /M "Do you want to download it? (Y/N)"
    if errorlevel 2 (
        echo HoloPatcher is required to proceed.
        pause
        exit /b 1
    )

    echo Downloading HoloPatcher...
    powershell -Command "& {Invoke-WebRequest '!holoUrl!' -OutFile '!holoZip!'}"

    if exist "!holoZip!" (
        echo Extracting HoloPatcher...
        powershell -Command "Expand-Archive -Path '!holoZip!' -DestinationPath '!patchDir!\extracted' -Force"
        del "!holoZip!"
        
        for /d %%D in ("!patchDir!\extracted\*") do set "extractedFolder=%%D"

        if not defined extractedFolder (
            echo ERROR: No extracted folder found.
            pause
            exit /b 1
        )

        if exist "!extractedFolder!\HoloPatcher.exe" (
            move /Y "!extractedFolder!\HoloPatcher.exe" "!patchDir!\HoloPatcher.exe"
        ) else (
            echo ERROR: HoloPatcher.exe not found in extracted folder.
            pause
            exit /b 1
        )

        rd /S /Q "!patchDir!\extracted"
        echo Cleaning Directory
    ) else (
        echo ERROR: Download failed.
        pause
        exit /b 1
    )
)


:: Main Choices (should be ran in numerical order, once per launch required because of virtual file directory shinanigans)
echo Choose an option:
echo [1] Nuke PATCHED FILES and Generate List of files in Install Directory
echo [2] Virtual Copy - copies files that will be modified by tslpatcher to the virtual directory
echo [3] Multi Patcher - runs all tslpatcher mods in modlist order
echo [4] Exit

choice /c 1234 /n /m "Enter your choice: "

if errorlevel 4 exit
if errorlevel 3 call multipatch.bat
if errorlevel 2 call virtualcopy.bat
if errorlevel 1 (
	echo .
	echo .
	rmdir /s "%modsDir%\PATCHED FILES"
	mkdir "%modsDir%\PATCHED FILES"
	echo Folder cleared.
	call filescan.bat

)
