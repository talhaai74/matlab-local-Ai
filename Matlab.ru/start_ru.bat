@echo off
setlocal DisableDelayedExpansion
rem ============================================================================
rem  ru engine: starts the Ollama AI engine of THIS folder (pendrive) by hand.
rem  You normally do NOT need this: typing  ru  in MATLAB starts the engine itself
rem  and also adapts the graphics settings to the PC.
rem  Keep this window open while you use ru; close it to free the memory.
rem  Everything comes from this folder: nothing installed on the PC is used.
rem ============================================================================
set "RU_DIR=%~dp0"
set "OLLAMA_EXE=%RU_DIR%ollama\ollama.exe"
if exist "%OLLAMA_EXE%" goto found
echo The AI engine is not in this folder:
echo   "%OLLAMA_EXE%"
echo Run setup_ru.bat once on a PC with internet; it puts the engine and the models here.
pause
exit /b 1
:found

netstat -ano | findstr /r /c:"127.0.0.1:11435 .*LISTENING" >nul
if errorlevel 1 goto start
echo An AI engine is already running on port 11435. In MATLAB, ru checks that it is the one
echo of this folder and restarts it from here when it is not.
timeout /t 5 >nul
exit /b 0

:start
rem Nothing from this PC: remove its Ollama and graphics settings, use only Windows' own folders.
for /f "delims==" %%V in ('set OLLAMA_ 2^>nul') do set "%%V="
set "CUDA_VISIBLE_DEVICES="
set "HIP_VISIBLE_DEVICES="
set "ROCR_VISIBLE_DEVICES="
set "GPU_DEVICE_ORDINAL="
set "GGML_VK_VISIBLE_DEVICES="
set "CUDA_PATH="
set "PATH=%RU_DIR%ollama;%RU_DIR%ollama\lib\ollama;%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"
rem The engine's own files (key, temporary files) stay in this folder too.
if not exist "%RU_DIR%brain\home" mkdir "%RU_DIR%brain\home"
if not exist "%RU_DIR%brain\tmp" mkdir "%RU_DIR%brain\tmp"
set "USERPROFILE=%RU_DIR%brain\home"
set "HOME=%RU_DIR%brain\home"
set "TMP=%RU_DIR%brain\tmp"
set "TEMP=%RU_DIR%brain\tmp"
set "OLLAMA_MODELS=%RU_DIR%model"
set "OLLAMA_HOST=127.0.0.1:11435"
rem never delete model files on the pendrive, keep one model in memory for 60 min,
rem allow 30 min to load a big model from a slow pendrive
set "OLLAMA_NOPRUNE=1"
set "OLLAMA_KEEP_ALIVE=60m"
set "OLLAMA_LOAD_TIMEOUT=30m"
set "OLLAMA_MAX_LOADED_MODELS=1"
set "OLLAMA_NUM_PARALLEL=1"

echo Starting the ru engine: "%OLLAMA_EXE%"
echo Models folder: "%OLLAMA_MODELS%"
echo Keep this window open while you use ru in MATLAB.
"%OLLAMA_EXE%" serve
