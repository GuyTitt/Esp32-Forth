@echo off
setlocal enabledelayedexpansion

set version_lanceur=4.0
cls
echo --------------------------------------------------------------------------------
echo [ETAPE 1] LANCEUR DE CONSTRUCTION ESP-FORTH V %version_lanceur%
echo           (Initialisation de l'environnement IDF et lancement du constructeur Python)
echo --------------------------------------------------------------------------------

:: ==============================================================================
:: PARTIE 1: INITIALISATION DE L'ENVIRONNEMENT ESP-IDF
:: ==============================================================================

:: Si IDF_PATH est deja defini, l'environnement est pret (sauter l'initialisation)
if not defined IDF_PATH (
    echo [INFO] IDF_PATH non defini. Tentative d'initialisation via config locale.
    
    :: 1. Charger sources/config.bat pour recuperer IDF_EXPORT_SCRIPT
    if not exist sources\config.bat (
        echo [ERREUR FATALE] Fichier de configuration introuvable : sources\config.bat
        exit /b 1
    )
    
    :: Le fichier config.bat doit definir IDF_EXPORT_SCRIPT et NE DOIT PAS utiliser setlocal.
    call sources\config.bat

    if not defined IDF_EXPORT_SCRIPT (
        echo [ERREUR FATALE] Le script sources\config.bat n'a pas defini IDF_EXPORT_SCRIPT.
        echo Assurez-vous que le fichier contient la ligne "set IDF_EXPORT_SCRIPT=..."
        exit /b 1
    )
    
    :: 2. Initialisation de l'environnement IDF en executant le script export.bat
    echo [INFO] Initialisation de l'environnement IDF via: !IDF_EXPORT_SCRIPT!
    call "!IDF_EXPORT_SCRIPT!"

    :: Verification critique: Si export.bat echoue, IDF_PATH n'est pas defini.
    if not defined IDF_PATH (
        echo [ERREUR FATALE] Echec de l'initialisation de l'environnement IDF.
        echo Cela est critique. Verifiez votre installation ESP-IDF (versions Python).
        exit /b 1
    )
    
    echo [SUCCES] Environnement IDF charge.
) else (
    echo [INFO] IDF_PATH est deja defini. Environnement IDF est pret.
)

echo --------------------------------------------------------------------------------
echo [ETAPE 2] Lancement de l'orchestrateur Python
echo --------------------------------------------------------------------------------

:: Lancement du script d'orchestration Python (le vrai constructeur)
if not exist outils\constructeur.py (
    echo [ERREUR FATALE] Fichier constructeur Python introuvable : outils\constructeur.py
    echo Ce fichier est necessaire pour la construction V4.0.
    exit /b 1
)

python outils\constructeur.py

if errorlevel 1 (
    echo.
    echo ****
    echo **ECHEC DE LA CONSTRUCTION (Erreur dans outils\constructeur.py).**
    echo ****
    exit /b 1
)

echo.
echo ****
echo SUCCES : La construction complete a ete effectuee par outils\constructeur.py.
echo ****

rem fichier: outils\lanceur.bat version 4.0
