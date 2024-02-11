@echo off

mkdir "C:\XC\" 2>nul
xcopy "%~dp0setup.exe" "C:\XC\" /Y
xcopy "%~dp0Configuration-cc.xml" "C:\XC\" /Y

:: Demande l'élévation de privilèges administratifs
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotAdmin ) else ( powershell -Command "Start-Process '%0' -Verb RunAs" & exit /B )

:gotAdmin
:: Début du script PowerShell
@echo off
setlocal enabledelayedexpansion

:: Obtient le chemin complet du dossier où le script batch est exécuté
set "script_dir=%~dp0"

:: Début du code PowerShell interactif avec le chemin du script PS1 actuel
powershell -NoProfile -ExecutionPolicy Bypass -File "%script_dir%clean.ps1"
:: Fin du script PowerShell

pause