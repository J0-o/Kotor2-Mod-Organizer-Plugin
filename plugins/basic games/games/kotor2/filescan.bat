:: make list of files in installdir

echo Scanning %installdir% for all file names...
echo (This may take some time for large directories)

:: Generate a list of all file names (without paths)
dir /b /s "%installdir%" 2>nul ^
  | findstr /i /v "tslpatchdata" ^
  | findstr /r /v "^$" ^
  | findstr /r "." ^
  > "%tempfile%"


:: Remove duplicate entries and sort the file list
powershell -Command ^
    "(Get-Content '%tempfile%' | ForEach-Object { [System.IO.Path]::GetFileName($_) } ) | Set-Content '%filelist%' -Encoding utf8"

:: Cleanup temporary file
del "%tempfile%"

:: Check if the file was created
if exist "%filelist%" (
    echo Unique file list saved to %filelist%
) else (
    echo ERROR: No files found or invalid directory.
)
pause
exit