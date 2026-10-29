@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp0instalar.ps1" -RepoUrl https://github.com/dmazariegoso3-oss/argocd.git
pause
