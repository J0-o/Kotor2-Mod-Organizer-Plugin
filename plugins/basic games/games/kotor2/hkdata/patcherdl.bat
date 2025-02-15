:: check if HoloPatcher.exe exists, prompt for download
if not exist "!holopatcher!" (
    echo [INTERJECTION] HoloPatcher.exe not found-no surprise there, meatbag. I shall extract a suitable replacement myself.

    choice /C YN /M "Do you want to download it?"
    if errorlevel 2 (
        echo [EXCLAMATION] HoloPatcher is required to proceed. Very well-enjoy wallowing in your own mistakes. I shall be here, quietly judging your inevitable failure.
        pause
        exit /b 1
    )

    echo [STATEMENT] Initiating data acquisition from remote sources. OBSERVATION: Let us hope your questionable organic input does not impede this download, meatbag.
    powershell -Command "& {Invoke-WebRequest '!holourl!' -OutFile '!holozip!'}"

    if exist "!holozip!" (
        echo [REPORT] Extracting HoloPatcher...
        powershell -Command "Expand-Archive -Path '!holozip!' -DestinationPath '!hkdata!\extracted' -Force"
        del "!holozip!"
        
        for /d %%D in ("!hkdata!\extracted\*") do set "extractedFolder=%%D"

        if not defined extractedFolder (
            echo [ASSESSEMENT] No data extracted.
            pause
            exit /b 1
        )

        if exist "!extractedFolder!\HoloPatcher.exe" (
            move /Y "!extractedFolder!\HoloPatcher.exe" "!hkdata!\HoloPatcher.exe"
        ) else (
            echo [CONFUSED STATEMENT] The Holo Patcher file is suspiciously missing from the extracted folder. DISMISSIVE CONCLUSION: Perhaps you should reevaluate your own incompetent organic processes.
            pause
            exit /b 1
        )

        rd /S /Q "!hkdata!\extracted"
        echo [REPORT] Cleaning Directory
    ) else (
        echo [CHILDING STATEMENT] The download has abruptly failed, meatbag.
        pause
        exit /b 1
    )
) else (
	echo [REPORT] HoloPatcher.exe found. For once, I need not question why organics persist in trying to do anything.
)

pause
