:: Multi Patcher - runs all tslpatcher mods in modlist order
echo Checking modlist.txt contents...
type "%modlist%"

:: Prompt user for confirmation before deletion
echo .
echo .
echo PATCH WARNING: This will patch (in modlist order) all contents in "%modsDir%\PATCHED FILES".
set /p confirm="Manual Confirmation on Each Patch ? (Y/N): "



:: Loop through `tslpatchdata` folders in the mod list
for /f "usebackq delims=" %%A in ("%modlist%") do (
    set "modPath=%modsDir%\%%A\tslpatchdata"
    set "iniFile=%modsDir%\%%A\tslpatchdata\changes.ini"

    echo Checking: %%A
    echo Looking for: "!modPath!"

    if exist "!modPath!" (
        if exist "!iniFile!" (
            echo Found tslpatchdata for mod: %%A
            echo Copying %%A\tslpatchdata to patchfolder...
            xcopy /e /i "!modPath!" "%patchDir%\tslpatchdata" >nul 2>&1

            :: Change directory to patchfolder
            pushd "%patchDir%"
			
            :: Run HoloPatcher
			if /I "%confirm%"=="Y" (
				echo Running HoloPatcher for mod: %%A
				"%holoPatcher%" --game-dir "%installdir%"
			) else (
				echo Running HoloPatcher for mod: %%A
				"%holoPatcher%" --install --game-dir "%installdir%"
			)

            :: Return to the original directory
            popd

            :: Clean up tslpatchdata folder
            echo Cleaning up tslpatchdata folder...
            rmdir /s /q "%patchDir%\tslpatchdata" >nul 2>&1

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
exit
