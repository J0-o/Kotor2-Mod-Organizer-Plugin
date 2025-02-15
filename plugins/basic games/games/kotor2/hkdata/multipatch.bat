:: Multi Patcher - runs all tslpatcher mods in modlist order
echo Checking modlist.txt contents...
if not exist "%modlistinput%" (
    echo ERROR: %modlistinput% not found.
    pause
    exit /b 1
)

echo Processing %modlistinput% to generate modlist.txt...
if exist "%modlist%" del "%modlist%"
for /f "usebackq tokens=* delims=" %%I in ("%modlistinput%") do (
    set "mod=%%I"
    
    rem Remove a leading '+' if present
    if "!mod:~0,1!"=="+" set "mod=!mod:~1!"
    
    rem Remove a trailing space if present
    if "!mod:~-1!"==" " set "mod=!mod:~0,-1!"
    
    rem Check if the mod folder exists under %mods%
    if exist "%mods%\!mod!" (
        rem Use set /p to write without adding a trailing space
        <nul set /p ="!mod!" >> "%modlist%"
        rem Now output a newline without extra spaces
        echo.>> "%modlist%"
    ) else (
        echo Skipping !mod! - mod folder not found under "%mods%\!mod!"
    )
)

powershell -Command "$a = Get-Content '%modlist%'; [array]::Reverse($a); $a | Set-Content '%modlist%'"

echo.
echo Generated %modlist%:
type "%modlist%"

:: Delete timestamp.txt if it exists
if exist "hkdata\timestamp.txt" del "hkdata\timestamp.txt"

:: Prompt user for confirmation before deletion
echo .
echo .
echo PATCH WARNING: This will patch (in modlist order) all contents in "%mods%\PATCHED FILES".
set /p confirm="Manual Confirmation on Each Patch ? (Y/N): "

:: Loop through `tslpatchdata` folders in the mod list
for /f "usebackq delims=" %%A in ("%modlist%") do (
    set "modPath="
    set "iniFile="
    
    rem Search for a folder that starts with tslpatchdata under the mod directory
    for /d %%B in ("%mods%\%%A\tslpatchdata*") do (
        set "modPath=%%B"
        set "iniFile=%%B\changes.ini"
    )

    echo Checking: %%A
    echo Looking for: "!modPath!"

    if defined modPath (
        if exist "!iniFile!" (
            echo Found tslpatchdata for mod: %%A
            echo Copying %%A\tslpatchdata to patchfolder...
            xcopy /e /i "!modPath!" "%hkdata%\tslpatchdata" >nul 2>&1

            :: Change directory to patchfolder
            pushd "%hkdata%"
			
            :: Run HoloPatcher
			if /I "%confirm%"=="Y" (
				echo Running HoloPatcher for mod: %%A
				"%holoPatcher%" --game-dir "%mods%\PATCHED FILES"
			) else (
				echo Running HoloPatcher for mod: %%A
				"%holoPatcher%" --console --install --game-dir "%mods%\PATCHED FILES\"
			)

            :: Return to the original directory
            popd

            :: Clean up tslpatchdata folder
            echo Cleaning up tslpatchdata folder...
            rmdir /s /q "%hkdata%\tslpatchdata" >nul 2>&1

            set /a patchCount+=1
			
        ) else (
            echo ERROR: changes.ini not found in %%A\tslpatchdata
            set /a errorCount+=1
        )
    ) else (
        echo Skipping: No tslpatchdata found for %%A
    )
)

echo.
echo Number of mods with 'tslpatchdata' folder processed: %patchCount%
echo Number of mods with missing changes.ini: %errorCount%
echo HoloPatcher has been executed for applicable mods.
echo.

pause
