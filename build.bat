@echo off

:: =================================================================
:: 1. GESTION DE LA VERSION DU SCRIPT
:: =================================================================
set SCRIPT_VERSION=1.7.1
echo.
echo ===============================================================
echo [INFO] Script de construction build.bat (v%SCRIPT_VERSION%)
echo ===============================================================

:: =================================================================
:: 2. VERIFICATION DE L'ENVIRONNEMENT (PAS D'APPEL A export.bat)
:: =================================================================
if not defined IDF_PATH (
    echo.
    echo ERREUR: La variable d'environnement IDF_PATH n'est pas definie.
    echo Veuillez executer ce script a partir de la console "ESP-IDF 5.5 CMD".
    goto :error_exit
)

echo [INFO] Environnement ESP-IDF verifie. IDF_PATH: %IDF_PATH%

:: Si le fichier VERSION.txt existe encore de la version precedente, le supprimer
if exist VERSION.txt (
    del VERSION.txt
    echo [INFO] Suppression de l'ancien fichier VERSION.txt.
)

:: =================================================================
:: 3. COMPILATION
:: =================================================================
echo.
echo Construction du projet pour ESP32-S3...
idf.py set-target esp32s3
idf.py fullclean
idf.py build

if errorlevel 1 (
    echo.
    echo ERREUR: La compilation a echoue.
    goto :error_exit
)

:: =================================================================
:: 4. GENERATION DU FIRMWARE (UF2 pour Wokwi)
:: =================================================================
echo.
echo Generation du fichier UF2 pour Wokwi/Televersement...
idf.py uf2

if errorlevel 1 (
    echo.
    echo ERREUR: La generation du fichier UF2 a echoue.
    goto :error_exit
)

:: =================================================================
:: 5. FIN
:: =================================================================
echo.
echo Succes! Le fichier firmware est dans le repertoire build/uf2.bin

:: On utilise une version simple pour le fichier de sortie.
copy build\uf2.bin firmware_forth.uf2

echo [INFO] Fichier genere: firmware_forth.uf2
echo ===============================================================
goto :eof

:error_exit
echo.
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo Le processus de construction a echoue.
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
:: Fichier: build.bat, Localisation: /build.bat, Version: 1.7.1
