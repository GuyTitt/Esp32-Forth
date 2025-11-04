@echo on
setlocal enabledelayedexpansion

set version_lanceur=1.9
cls
echo --------------------------------------------------------------------------------
echo LANCEUR UNIVERSEL DE CONSTRUCTION (V %version_lanceur%)
echo --------------------------------------------------------------------------------

:: --- 1. Tentative d'initialisation de l'environnement IDF ---
echo [ETAPE 1] Initialisation de l'environnement IDF.

:: 1.1 Charger la configuration locale (doit definir IDF_TOOLS_PATH)
call .\sources\config.bat
echo [INFO] Test d'existance des 3 dossiers ESP-IDF
:: test d'existance des dossiers
REM Teste si nous sommes sous PowerShell ou CMD
echo %ComSpec% | findstr /i "powershell" >nul
set env_check=%ERRORLEVEL%

REM Initialiser une variable pour vérifier l'existence des dossiers
set folders_exist=true

REM Vérifier sous PowerShell ou CMD
if "%env_check%"=="0" (
    REM Si sous PowerShell
    powershell -Command "
    if ((Test-Path '%IDF_TOOLS_PATH%') -and (Test-Path '%IDF_EXPORT_SCRIPT%') -and (Test-Path '%IDF_PATH%')) { 
        echo 'Les Trois dossiers existent' 
    } else { 
        if (-not (Test-Path '%IDF_TOOLS_PATH%')) { echo 'Le dossier %IDF_TOOLS_PATH% n''existe pas' }
        if (-not (Test-Path '%IDF_EXPORT_SCRIPT%')) { echo 'Le dossier %IDF_EXPORT_SCRIPT% n''existe pas' }
        if (-not (Test-Path '%IDF_PATH%')) { echo 'Le dossier %IDF_PATH% n''existe pas' }
    }"
) else (
    REM Si sous CMD, utiliser if exist
    if not exist "%IDF_TOOLS_PATH%" (
        echo Le dossier "%IDF_TOOLS_PATH%" n'existe pas
        set folders_exist=false
    )
    if not exist "%IDF_EXPORT_SCRIPT%" (
        echo Le dossier "%IDF_EXPORT_SCRIPT%" n'existe pas
        set folders_exist=false
    )
    if not exist "%IDF_PATH%" (
        echo Le dossier "%IDF_PATH%" n'existe pas
        set folders_exist=false
    )

    REM Si tous les dossiers existent
    if "%folders_exist%"=="true" (
        echo Les Trois dossiers existent
    )
)

:: --- 2. Lancement du Constructeur ---
echo.
echo [ETAPE 2] Lancement du constructeur principal.

:: Verification de la disponibilite de PowerShell 7 (pwsh) pour la performance
if exist "%PROGRAMFILES%\PowerShell\7\pwsh.exe" (
    echo [INFO] PowerShell 7 detecte. Lancement de outils\lanceur.ps1.
    pwsh -File "outils\lanceur.ps1"
) else (
    echo [INFO] PowerShell 7 non detecte. Lancement de outils\lanceur.bat.
    call "outils\lanceur.bat"
)

if errorlevel 1 (
    echo.
    echo **** ERREUR DE CONSTRUCTION ****
    echo Le constructeur a echoue (voir les messages d'erreur ci-dessus).
    echo ****
    exit /b 1
)

echo --------------------------------------------------------------------------------
echo Construction terminee avec succes.
echo --------------------------------------------------------------------------------
exit /b 0

:: Fichier: lanceur.cmd, Version: 1.9
