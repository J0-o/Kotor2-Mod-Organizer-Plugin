:: Initialize counter
set counter=0

:: Iterate through each mod listed in %modlist%
for /f "usebackq delims=" %%A in ("%modlist%") do (
    set "modPath="
    set "iniFile="
    
    :: Search for a folder that starts with tslpatchdata under the mod directory
    for /d %%B in ("%mods%\%%A\tslpatchdata*") do (
        set "modPath=%%B"
        set "iniFile=%%B\changes.ini"
    )

    echo Checking mod: %%A
    echo Looking for folder: "!modPath!"

    if defined modPath (
        if exist "!iniFile!" (
            echo Found tslpatchdata for mod: %%A
            :: Extract folder name and parent directory from modPath
            for %%F in ("!modPath!") do (
                set "folderName=%%~nF"
                set "folderPath=%%~dpF"
            )
            :: Rename the folder by appending _<counter> to its name
            echo Renaming "!modPath!" to "tslpatchdata_!counter!"
            ren "!modPath!" "tslpatchdata_!counter!"
            set /a counter=counter+1
        ) else (
            echo Skipping: No changes.ini found in "!modPath!" for mod %%A
        )
    ) else (
        echo No tslpatchdata folder found for mod %%A
    )
)

endlocal
pause
