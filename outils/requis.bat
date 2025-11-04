@echo off
setlocal enabledelayedexpansion

set version_requis=1.9
echo [INFO] Fichier outils\requis.bat, Version: %version_requis%

:: Definir la liste des fichiers sources critiques pour la construction
:: IMPORTANT : Tous les chemins sont mis a jour pour pointer vers le dossier 'sources\'
set REQUIRED_FILES=sources\CMakeLists.txt sources\main\CMakeLists.txt sources\main\forth_core.S sources\main\main.c sources\config.ini outils\lanceur.bat outils\mkuf2.py outils\nettoyage.bat outils\requis.bat outils\constructeur.py

:: Fichier: outils\requis.bat, Version: 1.9
