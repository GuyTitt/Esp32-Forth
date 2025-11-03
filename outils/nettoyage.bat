@echo off
setlocal enabledelayedexpansion

:: --- Configuration ---
set TARGET_DIR=sources
set BUILD_DIR=%TARGET_DIR%\build
set CIBLE_DIR=cible

cls
echo --------------------------------------------------------------------------------
echo [NETTOYAGE] Nettoyage des fichiers generes
echo --------------------------------------------------------------------------------

:: Nettoyage ESP-IDF (suppression des artefacts de build)
echo Nettoyage des artefacts de compilation IDF...
cd %TARGET_DIR%
idf.py fullclean 2>nul
cd ..

:: Suppression du repertoire de build
if exist %BUILD_DIR% (
    echo Suppression du repertoire de build : %BUILD_DIR%
    rmdir /s /q %BUILD_DIR%
) else (
    echo Le repertoire %BUILD_DIR% n'existe pas.
)

:: Suppression des binaires finaux
if exist %CIBLE_DIR% (
    echo Suppression des binaires dans cible/
    del /q %CIBLE_DIR%\*.uf2 2>nul
    del /q %CIBLE_DIR%\*.bin 2>nul
)

echo --------------------------------------------------------------------------------
echo Nettoyage termine. Vous pouvez maintenant relancer construction.bat
echo --------------------------------------------------------------------------------
exit /b 0

:: Fichier: outils/nettoyage.bat, Version: 1.0