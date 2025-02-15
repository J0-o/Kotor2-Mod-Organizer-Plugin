:: Make list of files in installdir

echo [REPORT] Scanning %installdir% for all file names...
echo [NOTE] This may take some time for large directories

type nul >  "%templist%"
type nul >  "%filelist%"
type nul >  "%filepathlist%"

:: Generate a list of all file names (including full paths)
dir /b /s "%installdir%" 2>nul ^
  | findstr /i /v "tslpatchdata" ^
  | findstr /r /v "^$" ^
  | findstr /r "." ^
  > "%templist%"

:: Sort the list and remove any duplicate entries (keeping full paths)
powershell -Command ^
    "(Get-Content '%templist%' | Sort-Object | Get-Unique) | Set-Content '%filepathlist%' -Encoding utf8"

:: Cleanup temporary file
del "%templist%"

:: Output list of files without paths
powershell -Command ^
	"(Get-Content '%filepathlist%') | ForEach-Object { Split-Path $_ -Leaf } | Set-Content '%filelist%' -Encoding utf8"


:: Check if the file was created
if exist "%filelist%" (
    echo [REPORT] File list with locations saved to %filepathlist%
) else (
    powershell write-host -fore Red [ERROR] No files found or invalid directory.
)

pause