@echo off
setlocal enabledelayedexpansion

set version_requis=2.1
echo [INFO] Fichier outils\requis.bat, Version: %version_requis%

:: Definir la liste des fichiers sources critiques pour la construction
:: IMPORTANT : Tous les chemins sont mis a jour pour pointer vers le dossier 'sources\' ou 'outils\'
set REQUIRED_FILES=sources\CMakeLists.txt sources\main\CMakeLists.txt sources\main\forth_core.S sources\main\main.c sources\config.ini sources\config.bat outils\lanceur.bat outils\mkuf2.py outils\check_folder.exe

:: Fichier: outils\requis.bat, Version: 2.1
