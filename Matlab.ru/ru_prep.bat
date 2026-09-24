@echo off
setlocal EnableExtensions EnableDelayedExpansion
title ru lab prep - free memory for MATLAB and the AI
rem ============================================================================
rem  ru_prep.bat - run on a lab PC BEFORE starting MATLAB and ru.
rem  It frees memory by closing YOUR OWN heavy programs: web browsers, chat,
rem  music/video players, game launchers and a leftover ru engine.
rem  It never touches Windows, MATLAB, antivirus, lab or exam software, or other
rem  users' programs, and it changes no settings. Word, Excel, PowerPoint and
rem  other document programs are only asked to close, so they can offer to save.
rem  It asks before closing anything.
rem
rem    double-click           shows what is running and asks
rem    ru_prep.bat /y         closes without asking (used by  ru prep  in MATLAB)
rem    ru_prep.bat /y /keep   same, but keeps a running ru engine
rem ============================================================================
set "AUTO=0"
set "KEEP=0"
for %%A in (%*) do (
    if /i "%%~A"=="/y" set "AUTO=1"
    if /i "%%~A"=="/keep" set "KEEP=1"
)
set "ME=%USERDOMAIN%\%USERNAME%"

echo.
echo  ru lab prep: free memory for MATLAB and the AI
echo  ----------------------------------------------
call :mem "before"

rem Programs that are safe to close. MATLAB is never in this list.
set APPS=chrome.exe msedge.exe firefox.exe opera.exe brave.exe vivaldi.exe iexplore.exe ^
 Teams.exe ms-teams.exe Discord.exe Telegram.exe WhatsApp.exe Messenger.exe Skype.exe Zoom.exe ^
 Spotify.exe vlc.exe wmplayer.exe Music.UI.exe Video.UI.exe ^
 steam.exe steamwebhelper.exe EpicGamesLauncher.exe Battle.net.exe
if "%KEEP%"=="0" set APPS=%APPS% ollama.exe
rem Document programs: closed normally only (never forced), so unsaved work can be saved.
set DOCS=WINWORD.EXE EXCEL.EXE POWERPNT.EXE ONENOTE.EXE OUTLOOK.EXE MSACCESS.EXE MSPUB.EXE ^
 AcroRd32.exe Acrobat.exe FoxitPDFReader.exe SumatraPDF.exe notepad++.exe

set "FOUND="
for %%P in (%APPS%) do (
    tasklist /NH /FI "IMAGENAME eq %%P" /FI "USERNAME eq %ME%" 2>nul | find /i "%%P" >nul && set "FOUND=!FOUND! %%P"
)
set "FOUNDDOCS="
for %%P in (%DOCS%) do (
    tasklist /NH /FI "IMAGENAME eq %%P" /FI "USERNAME eq %ME%" 2>nul | find /i "%%P" >nul && set "FOUNDDOCS=!FOUNDDOCS! %%P"
)
if defined FOUNDDOCS (
    echo  Your document programs:%FOUNDDOCS%
    echo  They will be asked to close; answer their Save questions.
    set "DOCSOK=1"
    if "%AUTO%"=="0" (
        choice /C YN /M "  Close them now"
        if errorlevel 2 set "DOCSOK=0"
    )
    if "!DOCSOK!"=="1" for %%P in (%FOUNDDOCS%) do taskkill /IM %%P /FI "USERNAME eq %ME%" >nul 2>&1
)
if not defined FOUND (
    echo  None of your heavy programs are running.
    goto after
)
echo  Your programs that use a lot of memory:%FOUND%
echo  Unsaved work in them will be lost ^(browser tabs can usually be restored^).
if "%AUTO%"=="0" (
    choice /C YN /M "  Close them now"
    if errorlevel 2 goto after
)
rem First ask them to close normally, then force whatever is still open.
for %%P in (%FOUND%) do taskkill /T /IM %%P /FI "USERNAME eq %ME%" >nul 2>&1
ping -n 4 127.0.0.1 >nul
for %%P in (%FOUND%) do taskkill /F /T /IM %%P /FI "USERNAME eq %ME%" >nul 2>&1
echo  Closed.

:after
echo.
echo  Biggest programs still running (close yours by hand if you do not need them):
powershell -NoProfile -Command "Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 8 @{n='Program';e={$_.ProcessName}},@{n='Memory (MB)';e={[int]($_.WorkingSet64/1MB)}} | Format-Table -AutoSize | Out-String -Width 80" 2>nul
if errorlevel 1 echo  ^(PowerShell is blocked on this PC; the list cannot be shown^)
call :mem "after"
echo.
if "%AUTO%"=="0" (
    echo  Next: open MATLAB and type
    echo     cd '%~dp0'
    echo     ru start
    echo.
    pause
)
exit /b 0

:mem
set "RAM="
for /f "usebackq delims=" %%M in (`powershell -NoProfile -Command "$o = Get-CimInstance Win32_OperatingSystem; '{0:N1} GB free of {1:N1} GB, processor load {2}%%' -f ($o.FreePhysicalMemory/1MB), ($o.TotalVisibleMemorySize/1MB), [int](Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average" 2^>nul`) do set "RAM=%%M"
if defined RAM (
    echo  Memory %~1: !RAM!
) else (
    echo  Memory %~1: could not be measured on this PC
)
exit /b 0
