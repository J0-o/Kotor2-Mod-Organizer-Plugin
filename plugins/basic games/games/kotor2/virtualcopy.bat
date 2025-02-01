:: Virtual Copy - copies files that will be modified by tslpatcher to the virtual directory
echo Mods Directory: !modsDir!
echo Overwrite Directory: !overwriteDir!


:: Grab enabled Mods from modlist
powershell -Command ^
    "$lines = Get-Content '%modlistinput%' | Where-Object { $_ -like '+*' } | ForEach-Object { $_.Substring(1).Trim() }; [Array]::Reverse($lines); $lines | Set-Content '%modlist%'"
echo Mod Order Extracted

set "modifiedTemp=modified_temp.txt"
set "modifiedFiles=modified_files.txt"

:: Clear previous modified files lists
echo. > "%modifiedFiles%"
echo. > "%modifiedTemp%"

:: Define the list of file extensions to check (formatted for regex matching)
set "extensions=\.2da|\.asi|\.bic|\.bif|\.bik|\.bmp|\.dlg|\.erf|\.flt|\.gui|\.jrl|\.lip|\.lyt|\.mdl|\.mdx|\.mod|\.mp3|\.ncs|\.nss|\.rim|\.tga|\.tlk|\.txi|\.utc|\.ute|\.uti|\.utw|\.vis|\.wav|\.wok"

:: Clear the modified files list
echo. > "%modifiedFiles%"

for /f "usebackq delims=" %%A in ("%modlist%") do (
    if exist "%modsDir%\%%A\tslpatchdata\changes.ini" (
        echo Extracting modified files from changes.ini for %%A...

        :: Step 1: Extract lines that contain both "=" and a valid extension
        powershell -Command ^
        "(Get-Content '%modsDir%\%%A\tslpatchdata\changes.ini' | Where-Object {$_ -match '=.+' -and $_ -match '%extensions%'} ) | Add-Content -Encoding utf8 '%modifiedTemp%'"
    ) else (
        echo ERROR: changes.ini not found in %%A\tslpatchdata
        set /a errorCount+=1
    )
)


:: Step 2: Remove lines that contain 'Required='
powershell -Command ^
    "(Get-Content '%modifiedTemp%' | Where-Object {$_ -notmatch '^Required='}) | Set-Content '%modifiedTemp%' -Encoding utf8"

:: Step 3: Remove everything before '=' and the '=' itself to keep only filenames
powershell -Command ^
    "(Get-Content '%modifiedTemp%' | ForEach-Object { ($_ -split '=', 2)[-1] }) | Set-Content '%modifiedTemp%' -Encoding utf8"
	
:: Step 4: remove directories from file name
powershell -Command ^
    "(Get-Content '%modifiedTemp%' | ForEach-Object { [System.IO.Path]::GetFileName($_) }) | Set-Content '%modifiedTemp%' -Encoding utf8"

:: Step 5: Remove duplicate lines
powershell -Command ^
    "(Get-Content '%modifiedTemp%' | Sort-Object -Unique) | Set-Content '%modifiedFiles%' -Encoding utf8"
	
del %modifiedTemp%

echo Finished processing mod files.

:: Search for and copy modified files to overwrite folder, ignoring tslpatchdata
echo.
echo Searching and copying modified files...

:: Ensure the file exists
if not exist "!modlistinput!" (
    echo Error: File "!modlistinput!" not found.
    exit /b 1
)

:: Copy Files
:: Main loop: For each line (filename) in modifiedFiles
for /f "usebackq delims=" %%D in ("%modifiedFiles%") do (
    :: Check if %%D is in filelist.txt
    findstr /i /x /c:"%%D" "%filelist%" >nul 2>&1
    if errorlevel 1 (
        echo NO FILE TO COPY: %%D
    ) else (
        :: If match found, do a recursive search for %%D in installdir
        for /f "delims=" %%F in ('
            dir /b /s "%installdir%\%%D" 2^>nul ^| find /i /v "tslpatchdata\"
        ') do (
            set "sourceFile=%%F"
            set "relativePath=!sourceFile:%installdir%=!"
            set "destFile=%modsDir%\PATCHED FILES\!relativePath!"

            echo Copying "%%F" to "!destFile!"...
            mkdir "!destFile!\.." 2>nul
            copy "%%F" "!destFile!" >nul
        )
    )
)

echo .
echo The full modified file list has been saved to "%modifiedFiles%".
echo .
pause
exit
