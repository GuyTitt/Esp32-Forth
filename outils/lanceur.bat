@echo off
setlocal enabledelayedexpansion
cls
set version_lanceur=3.0

echo --------------------------------------------------------------------------------
echo [ETAPE 0] LANCEUR DE CONSTRUCTION ESP-FORTH V %version_lanceur%
echo           (assemble, compile, lie et met en forme le binaire UF2)
echo --------------------------------------------------------------------------------
echo lancement de outils\lanceur.bat
echo --------------------------------------------------------------------------------

:: --------------------------------------------------------------------------------
:: Verification de l'environnement et Definition des repertoires
:: --------------------------------------------------------------------------------
:: Verification de IDF_PATH
if not defined IDF_PATH (
    echo **ERREUR: La variable d'environnement IDF_PATH n'est pas definie.**
    echo Veuillez executer export.bat dans le repertoire d'installation de l'ESP-IDF.
    exit /b 1
)

:: Definir les repertoires
set LOG_DIR=build\log
set CIBLE_DIR=cible
set REQUIS_BAT=outils\requis.bat
set VERSION_LOG_FILE=%LOG_DIR%\lanceur.log

:: Creation des repertoires cible et log (2>nul supprime le bruit "Le chemin d’accès spécifié est introuvable")
if not exist %LOG_DIR% mkdir %LOG_DIR% 2>nul
if not exist %CIBLE_DIR% mkdir %CIBLE_DIR% 2>nul

:: Suppression des anciens logs AVANT de commencer l'écriture
if exist %VERSION_LOG_FILE% del %VERSION_LOG_FILE% 2>nul
if exist build\log\build.log del build\log\build.log 2>nul


:: --------------------------------------------------------------------------------
echo [ETAPE 1] Verification de l'environnement et des logs
echo --------------------------------------------------------------------------------
echo [ETAPE 1] Verification de l'environnement et des logs >> %VERSION_LOG_FILE%
echo -------------------------------------------------------------------------------- >> %VERSION_LOG_FILE%


:: --------------------------------------------------------------------------------
echo [ETAPE 2] Nettoyage complet
echo --------------------------------------------------------------------------------
echo [ETAPE 2] Nettoyage complet >> %VERSION_LOG_FILE%
echo -------------------------------------------------------------------------------- >> %VERSION_LOG_FILE%

echo Nettoyage des fichiers precedents...
:: idf.py fullclean supprime les dossiers build et les fichiers temporaires dans cible/
idf.py fullclean --project-dir sources 2>nul
if exist %CIBLE_DIR%\*.bin del %CIBLE_DIR%\*.bin 2>nul
if exist %CIBLE_DIR%\*.uf2 del %CIBLE_DIR%\*.uf2 2>nul


:: --------------------------------------------------------------------------------
echo [ETAPE 2.1] Creation du log
echo --------------------------------------------------------------------------------
echo [ETAPE 2.1] Creation du log >> %VERSION_LOG_FILE%
echo -------------------------------------------------------------------------------- >> %VERSION_LOG_FILE%

echo ------------------------------------------------------------ >> %VERSION_LOG_FILE%
echo Log de Construction Forth - Verification des versions >> %VERSION_LOG_FILE%
echo Programme outils\lanceur.bat V %version_lanceur% Date : !date! !time! >> %VERSION_LOG_FILE%
echo ------------------------------------------------------------ >> %VERSION_LOG_FILE%

:: --------------------------------------------------------------------------------
echo [ETAPE 3] Journalisation des versions des fichiers sources
echo --------------------------------------------------------------------------------
echo [ETAPE 3] Journalisation des versions des fichiers sources >> %VERSION_LOG_FILE%
echo -------------------------------------------------------------------------------- >> %VERSION_LOG_FILE%

:: Appel de requis.bat pour definir la liste REQUIRED_FILES
call %REQUIS_BAT% 2>> %VERSION_LOG_FILE%

:: Journalisation de la version du script lanceur
echo [INFO] Fichier outils\lanceur.bat, Version: %version_lanceur%
echo [INFO] Fichier outils\lanceur.bat, Version: %version_lanceur% >> %VERSION_LOG_FILE%

:: Boucle pour tester l'existence de chaque fichier requis et extraire sa version
for %%F in (!REQUIRED_FILES!) do call :LogFileVersion "%%F"

echo. >> %VERSION_LOG_FILE%
echo Journal de version cree : %VERSION_LOG_FILE%

:: --------------------------------------------------------------------------------
echo [ETAPE 4] Lancement de la Construction
echo --------------------------------------------------------------------------------
echo [ETAPE 4] Lancement de la Construction >> %VERSION_LOG_FILE%
echo -------------------------------------------------------------------------------- >> %VERSION_LOG_FILE%

:: idf.py build (alias: all)
idf.py build --project-dir sources 1>> %VERSION_LOG_FILE% 2>>&1
if errorlevel 1 (
    echo.
    echo ****
    echo **Le processus de construction a echoue.**
    echo ****
    echo **Le processus de construction a echoue.** >> %VERSION_LOG_FILE%
    exit /b 1
)

:: --------------------------------------------------------------------------------
echo [ETAPE 5] Post-Construction (Creation de l'UF2)
echo --------------------------------------------------------------------------------
echo [ETAPE 5] Post-Construction (Creation de l'UF2) >> %VERSION_LOG_FILE%
echo -------------------------------------------------------------------------------- >> %VERSION_LOG_FILE%


:: Copie du binaire principal vers le dossier cible
copy sources\build\forth_interpreter.bin %CIBLE_DIR%\forth_interpreter.bin >nul
echo [INFO] Binaire copie : %CIBLE_DIR%\forth_interpreter.bin
echo [INFO] Binaire copie : %CIBLE_DIR%\forth_interpreter.bin >> %VERSION_LOG_FILE%

:: Generation du fichier UF2 (Utilisation du script mkuf2.py local qui appelle le mkuf2 d'IDF)
python outils\mkuf2.py --input sources\build\forth_interpreter.bin --output %CIBLE_DIR%\firmware_forth.uf2 1>> %VERSION_LOG_FILE% 2>>&1
if errorlevel 1 (
    echo.
    echo **ERREUR: La creation du fichier UF2 a echoue.**
    echo ****
    echo **ERREUR: La creation du fichier UF2 a echoue.** >> %VERSION_LOG_FILE%
    exit /b 1
)

echo.
echo ****
echo Succes : Le firmware est dans le repertoire %CIBLE_DIR%\firmware_forth.uf2 
echo ****
echo Succes : Le firmware est dans le repertoire %CIBLE_DIR%\firmware_forth.uf2 >> %VERSION_LOG_FILE%


goto :eof

:: --- Sous-routine de Journalisation des Versions ---
:LogFileVersion
setlocal enabledelayedexpansion
set "FILENAME=%~1"
set "VERSION=Non trouvee"
set "PREFIX=//"
set "STATUS=[WARNING]"
set "DESCRIPTION=(format incorrect)"
set "EXISTS=0"

:: 1. Verifier l'existence du fichier et afficher
if exist "%FILENAME%" (
    set "EXISTS=1"
    echo Verification de %FILENAME%...
    echo Verification de %FILENAME%... >> %VERSION_LOG_FILE%
) else (
    echo **ERREUR: Fichier introuvable: %FILENAME%**
    echo **ERREUR: Fichier introuvable: %FILENAME%** >> %VERSION_LOG_FILE%
    exit /b 1
)


:: 2. Determiner le prefixe de commentaire par extension (simplifie)
set "EXT=%~x1"
if /i "%EXT%"==".s"   set "PREFIX=//|;;"
if /i "%EXT%"==".c"   set "PREFIX=//"
if /i "%EXT%"==".bat" set "PREFIX=rem"
if /i "%EXT%"==".txt" set "PREFIX=#"
if /i "%EXT%"==".md"  set "PREFIX=#"
if /i "%EXT%"==".asm" set "PREFIX=//|;;" :: Ajout pour l'assembleur

:: 3. Extraire les deux dernieres lignes (pour gerer l'espace ou le saut de ligne)
set "LINE1="
set "LINE2="
for /f "usebackq delims=" %%L in ("%FILENAME%") do (
    set "LINE1=!LINE2!"
    set "LINE2=%%L"
)

:: 4. Tester les deux dernieres lignes pour trouver la version
for %%L in ("!LINE1!" "!LINE2!") do (
    set "L=%%~L"

    :: Filtrer les lignes vides ou trop courtes
    if not "!L!"=="" (

        :: Tenter de trouver la ligne de version commentee
        echo !L! | findstr /r /i /c:"version[ :]*[0-9]" >nul

        if !errorlevel! == 0 (
            :: Tenter d'extraire la version (ex: "version 1.5" -> 1.5)
            for /f "tokens=2 delims=:" %%V in ('echo !L! ^| findstr /r /i /c:"version"') do (
                set "VERSION=%%V"
            )
            :: Nettoyer la version des espaces (trim)
            for /f "tokens=*" %%V in ("!VERSION!") do set "VERSION=%%V"
            
            if not "!VERSION!"=="Non trouvee" (
                set "STATUS=[INFO]"
                set "DESCRIPTION="
                goto :LogVersionFound
            )
        )
    )
)

:LogVersionFound
:: 5. Afficher le resultat
if "!DESCRIPTION!"=="" (
    echo %STATUS% %FILENAME%, Version: !VERSION!
) else (
    echo %STATUS% %FILENAME%, Version: !VERSION! !DESCRIPTION!
)

:: 6. Journaliser (LOG toujours, ERREUR en cas d'echec)
echo %STATUS% %FILENAME%, Version: !VERSION! !DESCRIPTION! >> %VERSION_LOG_FILE%

endlocal
exit /b 0

rem fichier: outils\lanceur.bat version 3.0
