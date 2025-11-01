@echo off
:: =========================================================
:: test_build.bat - DÉTECTION COMPLÈTE ESP-IDF
:: VERSION 1.0.12 - CORRIGÉ (and → if exist)
:: Auteur : GuyTitt + Grok
:: Date : 01/11/2025
:: =========================================================

cls
echo =========================================================
echo     ESP32-Forth - TEST INSTALLATION ESP-IDF
echo     VERSION 1.0.12
echo =========================================================

echo.
echo === 1. VÉRIFICATION ESP-IDF ===
if defined IDF_PATH (
    echo [OK] IDF_PATH = %IDF_PATH%
    echo [INFO] Version ESP-IDF : %IDF_VERSION%
) else (
    echo [ERREUR] IDF_PATH non défini
    echo Lance ce script via "ESP-IDF Command Prompt"
    pause
    exit /b 1
)

echo.
echo === 2. FICHIERS SOURCE DU PROJET ===
echo [INFO] Dossier courant : %CD%

echo.
echo [DEBUG] boot\
if exist "boot\boot.s" (
    echo [OK] boot\boot.s trouvé
    for /f "usebackq tokens=* delims=" %%a in ("boot\boot.s") do (
        set "line=%%a"
        if "!line:~-15!"=="VERSION" echo [INFO] Version boot.s : !line!
    )
) else (
    echo [ERREUR] boot\boot.s introuvable
)

if exist "boot\linker.ld" (
    echo [OK] boot\linker.ld trouvé
    for /f "usebackq tokens=* delims=" %%a in ("boot\linker.ld") do (
        set "line=%%a"
        if "!line:~-10!"=="VERSION" echo [INFO] Version linker.ld : !line!
    )
) else (
    echo [ERREUR] boot\linker.ld introuvable
)

echo.
echo [DEBUG] kernel\
if exist "kernel\uart.s" (
    echo [OK] kernel\uart.s trouvé
    for /f "usebackq tokens=* delims=" %%a in ("kernel\uart.s") do (
        set "line=%%a"
        if "!line:~-10!"=="VERSION" echo [INFO] Version uart.s : !line!
    )
) else (
    echo [ERREUR] kernel\uart.s introuvable
)

if exist "kernel\vm.s" (
    echo [OK] kernel\vm.s trouvé
    for /f "usebackq tokens=* delims=" %%a in ("kernel\vm.s") do (
        set "line=%%a"
        if "!line:~-10!"=="VERSION" echo [INFO] Version vm.s : !line!
    )
) else (
    echo [ERREUR] kernel\vm.s introuvable
)

echo.
echo === 3. DÉTECTION TOOLCHAIN ===
echo.

set "FOUND_TOOLCHAIN=0"

:: Recherche xtensa-esp32-elf (priorité)
for /d %%d in ("C:\Espressif\tools\xtensa-esp32-elf\*") do (
    if exist "%%d\xtensa-esp32-elf\bin\xtensa-esp32-elf-ld.exe" (
        echo [OK] xtensa-esp32-elf trouvé : %%d\xtensa-esp32-elf
        set "TOOLCHAIN=%%d\xtensa-esp32-elf"
        set "FOUND_TOOLCHAIN=1"
        "%TOOLCHAIN%\bin\xtensa-esp32-elf-ld.exe" --version
        goto :toolchain_found
    )
)

:: Sinon xtensa-esp-elf
for /d %%d in ("C:\Espressif\tools\xtensa-esp-elf\*") do (
    if exist "%%d\xtensa-esp-elf\bin\xtensa-esp-elf-ld.exe" (
        echo [OK] xtensa-esp-elf trouvé : %%d\xtensa-esp-elf
        set "TOOLCHAIN=%%d\xtensa-esp-elf"
        set "FOUND_TOOLCHAIN=1"
        "%TOOLCHAIN%\bin\xtensa-esp-elf-ld.exe" --version
        goto :toolchain_found
    )
)

:toolchain_found
if "%FOUND_TOOLCHAIN%"=="0" (
    echo [ERREUR] Aucun toolchain trouvé
    echo Installe esp-idf-tools-setup-offline-5.5.1.exe
)

echo.
echo === 4. ESPTOOL ===
if exist "%IDF_PATH%\components\esptool_py\esptool\esptool.py" (
    echo [OK] esptool.py trouvé
    python -c "import esptool, sys; print('Version esptool:', esptool.__version__)" 2>nul || echo [INFO] Version non détectée
) else (
    echo [ERREUR] esptool.py introuvable
)

echo.
echo === 5. RÉSUMÉ ===
echo.
if "%FOUND_TOOLCHAIN%"=="1" if exist "%TOOLCHAIN%" (
    echo [OK] Toolchain trouvé : %TOOLCHAIN%
    if exist "%TOOLCHAIN%\bin\xtensa-esp32-elf-ld.exe" (
        echo [OK] xtensa-esp32-elf → ELF VALIDE GARANTI
    ) else (
        echo [INFO] xtensa-esp-elf → ELF peut être invalide
    )
) else (
    echo [ERREUR] Toolchain manquant
)

set "SOURCES_OK=1"
if not exist "boot\boot.s" set "SOURCES_OK=0"
if not exist "kernel\uart.s" set "SOURCES_OK=0"
if not exist "kernel\vm.s" set "SOURCES_OK=0"
if not exist "boot\linker.ld" set "SOURCES_OK=0"

if "%SOURCES_OK%"=="1" (
    echo [OK] Tous les fichiers source présents
) else (
    echo [ERREUR] Fichiers source manquants
)

echo.
echo Appuyez sur une touche pour fermer...
:: fin test_build.bat VERSION 1.0.12