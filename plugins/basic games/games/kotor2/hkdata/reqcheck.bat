:: Chech if PATCHED FILES mod is disabled
findstr /C:"+PATCHED FILES" "%modlistinput%" >nul
if errorlevel 1 (
    echo [REPORT] PATCHED FILES mod is disabled as expected. Resuming...
) else (
	powershell write-host -fore Red [WARNING] PATCHED FILES mod must be disabled or removed. Exiting...
	pause
	exit
)