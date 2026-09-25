@echo off
setlocal EnableExtensions EnableDelayedExpansion
rem ============================================================================
rem  setup_ru.bat - run ONCE on a Windows PC with internet (as a normal user).
rem  1. downloads the portable Ollama engine into  <this folder>\ollama
rem  2. downloads the AI model(s) into            <this folder>\model
rem  After that the pendrive works offline on any Windows PC with MATLAB.
rem ============================================================================
set "RU_DIR=%~dp0"
set "OLLAMA_DIR=%RU_DIR%ollama"
set "OLLAMA_MODELS=%RU_DIR%model"
set "OLLAMA_HOST=127.0.0.1:11435"
set "OLLAMA_NOPRUNE=1"
cd /d "%RU_DIR%"

echo.
echo ru setup - folder: %RU_DIR%
set "DRV=%~d0"
for /f "usebackq delims=" %%F in (`powershell -NoProfile -Command "(Get-Volume -DriveLetter '!DRV:~0,1!').FileSystemType" 2^>nul`) do set "FS=%%F"
if defined FS echo Drive %~d0 file system: !FS!
if /i "!FS!"=="FAT32" (
    echo.
    echo WARNING: this drive is FAT32. FAT32 cannot store files larger than 4 GB, so only the
    echo small models ^(qwen2.5-coder:3b, qwen3.5:4b, qwen3.5:2b^) fit. To use 7B/9B models,
    echo copy your files elsewhere, format the pendrive as exFAT and copy them back.
)

rem ---- 1. portable Ollama ----------------------------------------------------
if exist "%OLLAMA_DIR%\ollama.exe" (
    echo Portable Ollama already present: %OLLAMA_DIR%\ollama.exe
) else (
    echo.
    echo Downloading the portable Ollama for Windows ^(about 1-2 GB^)...
    if not exist "%OLLAMA_DIR%" mkdir "%OLLAMA_DIR%"
    curl.exe -L --fail -o "%OLLAMA_DIR%\ollama-windows-amd64.zip" "https://ollama.com/download/ollama-windows-amd64.zip"
    if errorlevel 1 (
        echo Download failed. Check the internet connection, or download ollama-windows-amd64.zip from
        echo https://github.com/ollama/ollama/releases and unzip it into "%OLLAMA_DIR%".
        pause
        exit /b 1
    )
    echo Unpacking...
    tar -xf "%OLLAMA_DIR%\ollama-windows-amd64.zip" -C "%OLLAMA_DIR%"
    if errorlevel 1 powershell -NoProfile -Command "Expand-Archive -Force '%OLLAMA_DIR%\ollama-windows-amd64.zip' '%OLLAMA_DIR%'"
    if not exist "%OLLAMA_DIR%\ollama.exe" (
        echo Could not unpack Ollama. Unzip "%OLLAMA_DIR%\ollama-windows-amd64.zip" into that folder by hand.
        pause
        exit /b 1
    )
    del "%OLLAMA_DIR%\ollama-windows-amd64.zip"
)

rem ---- 2. models ---------------------------------------------------------------
echo.
echo Which model(s) do you want on the pendrive?
echo   1. qwen3.5:4b        3.4 GB  reads screenshots too, best choice for 8 GB RAM   [recommended]
echo   2. qwen2.5-coder:3b  1.9 GB  small and fast, text only (already used by ru before)
echo   3. qwen2.5-coder:7b  4.7 GB  stronger coder, text only, needs 16 GB RAM and exFAT/NTFS
echo   4. qwen3.5:9b        6.6 GB  strongest, reads images, needs 16 GB RAM and exFAT/NTFS
echo   5. qwen3.5:2b        2.7 GB  for weak PCs (4-6 GB RAM), reads images
echo Type one or more numbers separated by spaces (default 1 2):
set "CHOICE=1 2"
set /p "CHOICE=> "

rem An engine that is already running (ru, start_ru.bat, another copy of ru) would receive the
rem downloads into ITS model folder, so stop it first.
call :stopengine
start "ru setup engine" /min "%OLLAMA_DIR%\ollama.exe" serve
echo Waiting for the engine...
set /a TRIES=0
:waitengine
curl.exe -s -m 2 http://127.0.0.1:11435/api/version >nul 2>&1
if not errorlevel 1 goto engineok
set /a TRIES+=1
if !TRIES! GEQ 60 (
    echo The engine did not start. Close any "ru engine" window and run setup_ru.bat again.
    pause
    exit /b 1
)
ping -n 2 127.0.0.1 >nul
goto waitengine
:engineok

for %%C in (!CHOICE!) do (
    set "M="
    if "%%C"=="1" set "M=qwen3.5:4b"
    if "%%C"=="2" set "M=qwen2.5-coder:3b"
    if "%%C"=="3" set "M=qwen2.5-coder:7b"
    if "%%C"=="4" set "M=qwen3.5:9b"
    if "%%C"=="5" set "M=qwen3.5:2b"
    if defined M (
        echo.
        echo Downloading !M! into %OLLAMA_MODELS% ...
        "%OLLAMA_DIR%\ollama.exe" pull !M!
        if errorlevel 1 echo Download of !M! failed - run setup_ru.bat again to resume.
    )
)

echo.
echo Models in %OLLAMA_MODELS%:
"%OLLAMA_DIR%\ollama.exe" list
call :stopengine
echo.
echo Done. In MATLAB on any PC:   cd %RU_DIR%   then   ru status   and   ru help
echo ru chooses a small model automatically; for the big one type  ru model qwen3.5:9b
pause
exit /b 0

:stopengine
rem Ends the engine on port 11435 together with its model processes.
for /f "tokens=5" %%P in ('netstat -ano -p tcp ^| findstr /r /c:"127\.0\.0\.1:11435 .*0\.0\.0\.0:0"') do taskkill /F /T /PID %%P >nul 2>&1
ping -n 3 127.0.0.1 >nul
exit /b 0
