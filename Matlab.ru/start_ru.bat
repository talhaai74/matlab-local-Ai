@echo off
setlocal
rem ru engine: serves the models stored on this pendrive.
set "OLLAMA_MODELS=%~dp0models"
set "OLLAMA_HOST=127.0.0.1:11434"

rem Use a portable Ollama copied to <pendrive>\ru_portable\ollama if present,
rem otherwise the Ollama installed on this PC.
set "OLLAMA_EXE=ollama"
if exist "%~dp0ollama\ollama.exe" set "OLLAMA_EXE=%~dp0ollama\ollama.exe"

rem The Ollama tray app also listens on port 11434, but it serves the models on
rem C:, not the ones on this pendrive. Only one server can own the port.
netstat -ano | findstr /r /c:":11434 .*LISTENING" >nul
if not errorlevel 1 (
    echo Another Ollama server is already running on port 11434, probably the tray app.
    echo It serves the models on C:, not the ones on this pendrive.
    choice /c YN /m "Stop it and start the pendrive engine"
    if errorlevel 2 exit /b 1
    taskkill /im "ollama app.exe" /f >nul 2>&1
    taskkill /im ollama.exe /f >nul 2>&1
    timeout /t 2 /nobreak >nul
)

echo Starting ru engine with models from %OLLAMA_MODELS%
"%OLLAMA_EXE%" serve
