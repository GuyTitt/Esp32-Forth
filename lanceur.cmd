@echo off
setlocal

:: =================================================================================
:: FICHIER: lanceur.cmd
:: VERSION: 3.6 - Correction de l'appel a mkuf2.py pour utiliser les flags --input et --output.
:: OBJET: Script de demarrage Forth a executer DANS la console ESP-IDF pre-configuree.
:: =================================================================================

cls
echo =================================================================
echo.
echo    Lancement du Projet ESP32-Forth
echo    VERSION: 3.6 (Correction Mkuf2 Args)
echo.
echo =================================================================
echo.

:: -----------------------------------------------------------------
:: 1. Verification des variables (confirme que l'environnement IDF est charge)
:: -----------------------------------------------------------------
echo [1/5] Verification de l'environnement ESP-IDF...

if not defined IDF_PATH (
    echo.
    echo ERREUR [S3.6-E101]: La variable IDF_PATH n'est pas definie.
    echo.
    echo Veuillez executer ce script DANS la console fournie par ESP-IDF.
    goto :end
)

:: -----------------------------------------------------------------
:: 2. Deplacement vers le dossier 'sources'
:: -----------------------------------------------------------------
echo.
echo [2/5] Deplacement vers le dossier des sources...
pushd sources

if errorlevel 1 (
    echo.
    echo ERREUR [S3.6-E201]: Le dossier 'sources' n'a pas ete trouve. Verifiez la structure du projet.
    echo.
    goto :end
)

echo Repertoire de travail courant: %CD%

:: -----------------------------------------------------------------
:: 3. Nettoyage optionnel (si l'argument 'clean' est passe)
:: -----------------------------------------------------------------
if /i "%1"=="clean" (
    echo.
    echo [3/5] Argument 'clean' detecte. Nettoyage complet fullclean...
    idf.py fullclean
    if errorlevel 1 (
        echo.
        echo ERREUR [S3.6-E301]: La commande idf.py fullclean a echoue.
        popd
        goto :end
    )
) else (
    echo.
    echo [3/5] Mode normal : Construction simple.
)

:: -----------------------------------------------------------------
:: 4. Construction du Binaire
:: -----------------------------------------------------------------
echo.
echo [4/5] Construction du binaire Forth: idf.py build

:: Execution de la commande de construction (creation du binaire)
idf.py build

set BUILD_ERROR=%errorlevel%

:: Retour au repertoire initial
popd

if %BUILD_ERROR% neq 0 (
    echo.
    echo ERREUR [S3.6-E401]: La commande idf.py build a echoue.
    echo.
    echo Causes possibles:
    echo 1. Erreur de compilation voir les logs de la console.
    echo 2. Probl. de configuration essayez de relancer avec "lanceur.cmd clean".
    echo.
    goto :end
)

:: -----------------------------------------------------------------
:: 5. Generation du Livrable UF2 pour Wokwi CORRIGE
:: -----------------------------------------------------------------
echo.
echo [5/5] Generation du fichier UF2 pour Wokwi...

set BIN_NAME=forth_interpreter.bin
set BIN_PATH=sources\build\%BIN_NAME%
set UF2_PATH=firmware_forth.uf2

if not exist %BIN_PATH% (
    echo.
    echo ERREUR [S3.6-E501]: Binaire principal %BIN_NAME% non trouve a %BIN_PATH%.
    echo Verifiez le nom de votre projet ou le chemin de sortie.
    goto :end
)

echo Execution du script outils\mkuf2.py : %BIN_PATH% -> %UF2_PATH%
:: CORRECTION ICI : Utilisation des flags --input et --output
python outils\mkuf2.py --input %BIN_PATH% --output %UF2_PATH%

if errorlevel 1 (
    echo.
    echo ERREUR [S3.6-E502]: L'outil mkuf2.py a echoue.
    echo Verifiez que Python est dans votre PATH et que mkuf2.py fonctionne.
    goto :end
)

:: -----------------------------------------------------------------
:: Confirmation
:: -----------------------------------------------------------------
echo.
echo =================================================================
echo SUCCESS: Binaire cree et %UF2_PATH% genere.
echo.
echo =================================================================

:end
pause
endlocal
:: Fichier outils/lanceur.bat version 3.6