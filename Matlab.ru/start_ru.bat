@echo off
setlocal
rem ============================================================================
rem  ru engine: starts the Ollama AI engine that serves the models on this pendrive.
rem  You normally do NOT need this: typing  ru  in MATLAB starts the engine itself,
rem  and that is better: ru then also adapts the graphics settings to the PC
rem  (integrated graphics off, processor-only when a graphics driver fails).
rem  Keep this window open while you use ru; close it to free the memory.
rem ============================================================================
set "RU_DIR=%~dp0"
set "OLLAMA_MODELS=%RU_DIR%model"
set "OLLAMA_HOST=127.0.0.1:11435"
rem never delete model files on the pendrive, keep one model in memory for 60 min,
rem allow 30 min to load a big model from a slow pendrive
set "OLLAMA_NOPRUNE=1"
set "OLLAMA_KEEP_ALIVE=60m"
set "OLLAMA_LOAD_TIMEOUT=30m"
set "OLLAMA_MAX_LOADED_MODELS=1"
set "OLLAMA_NUM_PARALLEL=1"

set "OLLAMA_EXE="
if exist "%RU_DIR%ollama\ollama.exe" set "OLLAMA_EXE=%RU_DIR%ollama\ollama.exe"
if not defined OLLAMA_EXE if exist "%LOCALAPPDATA%\Programs\Ollama\ollama.exe" set "OLLAMA_EXE=%LOCALAPPDATA%\Programs\Ollama\ollama.exe"
if not defined OLLAMA_EXE (
    where ollama >nul 2>&1 && set "OLLAMA_EXE=ollama"
)
if not defined OLLAMA_EXE (
    echo Ollama was not found. Run setup_ru.bat once on a PC with internet
    echo ^(it puts a portable Ollama into "%RU_DIR%ollama"^), or install it from https://ollama.com
    pause
    exit /b 1
)

netstat -ano | findstr /r /c:"127.0.0.1:11435 .*LISTENING" >nul
if not errorlevel 1 (
    echo The ru engine is already running on port 11435. You can use ru in MATLAB now.
    timeout /t 5 >nul
    exit /b 0
)

echo Starting the ru engine: %OLLAMA_EXE%
echo Models folder: %OLLAMA_MODELS%
echo Keep this window open while you use ru in MATLAB.
"%OLLAMA_EXE%" serve
