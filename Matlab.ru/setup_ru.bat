@echo off
setlocal EnableExtensions EnableDelayedExpansion
rem ============================================================================
rem  setup_ru.bat - run ONCE on a Windows 10/11 PC with internet (as a normal user).
rem  Everything goes into THIS folder, nothing is installed on the PC:
rem    1. the portable Ollama engine  ->  <this folder>\ollama
rem    2. the AI model(s)             ->  <this folder>\model
rem  After that the folder works offline on any Windows 10/11 PC with MATLAB, from
rem  any drive letter or folder. Copy the WHOLE folder to move it.
rem ============================================================================
set "RU_DIR=%~dp0"
set "OLLAMA_DIR=%RU_DIR%ollama"
cd /d "%RU_DIR%"
if not exist "%RU_DIR%ru.m" goto notextracted
echo "%RU_DIR%" | findstr /i /l /c:"AppData\Local\Temp" >nul
if not errorlevel 1 goto notextracted

rem Nothing from this PC: its Ollama and graphics settings are removed for this window, the engine's
rem own files (key, temporary files) stay in this folder, and only Windows' own folders are on PATH.
for /f "delims==" %%V in ('set OLLAMA_ 2^>nul') do set "%%V="
set "CUDA_VISIBLE_DEVICES="
set "HIP_VISIBLE_DEVICES="
set "ROCR_VISIBLE_DEVICES="
set "GGML_VK_VISIBLE_DEVICES="
if not exist "%RU_DIR%brain\home" mkdir "%RU_DIR%brain\home"
if not exist "%RU_DIR%brain\tmp" mkdir "%RU_DIR%brain\tmp"
set "USERPROFILE=%RU_DIR%brain\home"
set "HOME=%RU_DIR%brain\home"
set "TMP=%RU_DIR%brain\tmp"
set "TEMP=%RU_DIR%brain\tmp"
set "PATH=%OLLAMA_DIR%;%OLLAMA_DIR%\lib\ollama;%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0"
set "OLLAMA_MODELS=%RU_DIR%model"
set "OLLAMA_HOST=127.0.0.1:11435"
set "OLLAMA_NOPRUNE=1"

echo.
echo ru setup - folder: %RU_DIR%
set "DRV=%~d0"
set "FS="
set "FREEMB="
for /f "usebackq delims=" %%F in (`powershell -NoProfile -Command "(Get-Volume -DriveLetter '!DRV:~0,1!').FileSystemType" 2^>nul`) do set "FS=%%F"
for /f "usebackq delims=" %%F in (`powershell -NoProfile -Command "[math]::Floor((Get-Volume -DriveLetter '!DRV:~0,1!').SizeRemaining/1MB)" 2^>nul`) do set "FREEMB=%%F"
if defined FS echo Drive %~d0 file system: !FS!
if defined FREEMB echo Free space on %~d0: !FREEMB! MB
if /i "!FS!"=="FAT32" (
    echo.
    echo WARNING: this drive is FAT32. FAT32 cannot store files larger than 4 GB, so qwen3.5:9b and
    echo qwen2.5-coder:7b cannot be stored here. To use them: copy your files elsewhere, format the
    echo pendrive as exFAT or NTFS ^(right-click the drive, Format^), and copy them back.
)

rem ---- 1. portable Ollama ----------------------------------------------------
if exist "%OLLAMA_DIR%\ollama.exe" if exist "%OLLAMA_DIR%\lib\ollama" (
    echo Portable Ollama already present: %OLLAMA_DIR%\ollama.exe
    goto models
)
echo.
echo Downloading the portable Ollama for Windows ^(about 2 GB; needs about 6 GB free while unpacking^)...
if not exist "%OLLAMA_DIR%" mkdir "%OLLAMA_DIR%"
set "ZIP=%OLLAMA_DIR%\ollama-windows-amd64.zip"
curl.exe -L --fail -C - -o "%ZIP%" "https://ollama.com/download/ollama-windows-amd64.zip"
if errorlevel 1 curl.exe -L --fail -o "%ZIP%" "https://github.com/ollama/ollama/releases/latest/download/ollama-windows-amd64.zip"
if errorlevel 1 (
    echo Download failed. Check the internet connection and run setup_ru.bat again, or download
    echo ollama-windows-amd64.zip from https://github.com/ollama/ollama/releases and unzip it into
    echo "%OLLAMA_DIR%".
    pause
    exit /b 1
)
echo Unpacking...
tar -xf "%ZIP%" -C "%OLLAMA_DIR%"
if errorlevel 1 powershell -NoProfile -Command "Expand-Archive -Force '%ZIP%' '%OLLAMA_DIR%'"
if not exist "%OLLAMA_DIR%\ollama.exe" (
    echo Could not unpack Ollama ^(is the drive full?^). Unzip "%ZIP%" into that folder by hand.
    pause
    exit /b 1
)
del "%ZIP%"

:models
rem ---- 2. models ---------------------------------------------------------------
echo.
echo Which model(s) do you want in this folder?
echo   1. qwen3.5:9b        6.6 GB  strongest, reads images; ru uses it by default   [recommended]
echo   2. qwen2.5-coder:3b  1.9 GB  small and fast, text only: ru model coder       [recommended]
echo   3. qwen3.5:4b        3.4 GB  medium, reads images
echo   4. qwen2.5-coder:7b  4.7 GB  stronger coder, text only
echo   5. qwen3.5:2b        2.7 GB  for very weak PCs, reads images
echo 9b needs about 8 GB of free memory on the exam PC; ru warns when a PC has less.
echo Type one or more numbers separated by spaces and press Enter (just Enter = 1 2):
set "CHOICE=1 2"
set /p "CHOICE=> "

rem An engine that is already running (ru, start_ru.bat, another copy of ru) would receive the
rem downloads into ITS model folder, so stop it first.
call :stopengine
start "ru setup engine" /min "%OLLAMA_DIR%\ollama.exe" serve
echo Waiting for the engine...
set /a TRIES=0
:waitengine
curl.exe -s --noproxy "*" -m 2 http://127.0.0.1:11435/api/version >nul 2>&1
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
    set "BIG="
    if "%%C"=="1" (set "M=qwen3.5:9b" & set "BIG=1")
    if "%%C"=="2" set "M=qwen2.5-coder:3b"
    if "%%C"=="3" set "M=qwen3.5:4b"
    if "%%C"=="4" (set "M=qwen2.5-coder:7b" & set "BIG=1")
    if "%%C"=="5" set "M=qwen3.5:2b"
    if defined M (
        if defined BIG if /i "!FS!"=="FAT32" (
            echo.
            echo Skipping !M!: its main file is larger than 4 GB and this drive is FAT32 ^(see above^).
            set "M="
        )
    )
    if defined M (
        echo.
        echo Downloading !M! into %OLLAMA_MODELS% ...
        "%OLLAMA_DIR%\ollama.exe" pull !M!
        if errorlevel 1 echo Download of !M! failed - run setup_ru.bat again to resume it.
    )
)

echo.
echo Models in %OLLAMA_MODELS%:
"%OLLAMA_DIR%\ollama.exe" list
call :stopengine
echo.
echo Done. Everything ru needs is in %RU_DIR%
echo In MATLAB on any PC:  cd to this folder, then  ru status  and  ru help
echo ru uses qwen3.5:9b by default; for the small model on one PC:  ru model coder
pause
exit /b 0

:notextracted
echo This setup is running from a temporary folder (inside a zip file?): %RU_DIR%
echo Extract the whole Matlab.ru folder to the pendrive first, then run setup_ru.bat from there.
pause
exit /b 1

:stopengine
rem Ends the engine on port 11435 together with its model processes.
for /f "tokens=5" %%P in ('netstat -ano -p tcp ^| findstr /r /c:"127\.0\.0\.1:11435 .*0\.0\.0\.0:0"') do taskkill /F /T /PID %%P >nul 2>&1
ping -n 3 127.0.0.1 >nul
exit /b 0
