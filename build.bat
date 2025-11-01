@echo off
:: =========================================================
:: build.bat - ESP32-Forth - VERSION 1.6.55
:: + Recherche xtensa-esp32-elf-ld.exe dans TOUT C:\Espressif
:: + Utilise le vrai toolchain ESP32
:: Auteur : GuyTitt + Grok
:: Date : 01/11/2025
:: =========================================================

cls
setlocal EnableDelayedExpansion

set "BUILD_VERSION=1.6.55"
set "LOG_DIR=log"
set "LOG_FILE=%LOG_DIR%\build.log"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
echo. > "%LOG_FILE%"

echo =========================================================
echo     ESP32-Forth Build System - VERSION %BUILD_VERSION%
echo     Auteur : GuyTitt + Grok
echo     Date   : 01/11/2025
echo     Log : %LOG_FILE%
echo =========================================================

:: --- VÉRIF IDF ---
if not defined IDF_PATH (
    echo [ERREUR] Lance via "ESP-IDF Command Prompt"
    exit /b 1
)
echo === ENV OK : %IDF_PATH%

:: --- TOOLCHAIN AUTO : RECHERCHE EXHAUSTIVE ---
set "FOUND=0"
set "LD_PATH="

echo [INFO] Recherche de xtensa-esp32-elf-ld.exe...
for /r "C:\Espressif" %%f in (xtensa-esp32-elf-ld.exe) do (
    set "LD_PATH=%%f"
    set "FOUND=1"
    echo [OK] xtensa-esp32-elf-ld.exe trouvé : %%f
    goto :toolchain_found
)

:toolchain_found
if "%FOUND%"=="0" (
    echo [ERREUR] xtensa-esp32-elf-ld.exe introuvable dans C:\Espressif
    echo Installe le toolchain ESP32 via ESP-IDF Tools Installer
    pause
    exit /b 1
)

:: Extraire le dossier bin
for %%f in ("%LD_PATH%") do set "TOOLCHAIN_BIN=%%~dpf"
set "TOOLCHAIN=!TOOLCHAIN_BIN:~0,-1!"

set "AS=%TOOLCHAIN%\bin\xtensa-esp32-elf-as.exe"
set "LD=%TOOLCHAIN%\bin\xtensa-esp32-elf-ld.exe"
set "OBJCOPY=%TOOLCHAIN%\bin\xtensa-esp32-elf-objcopy.exe"
set "ESPTOOL=python %IDF_PATH%\components\esptool_py\esptool\esptool.py"

echo [OK] Toolchain ESP32 : %TOOLCHAIN%

:: --- CHEMINS ---
set "BUILD_DIR=build"
set "LINKER=boot\linker.ld"
set "TARGET_ELF=%BUILD_DIR%\forth.elf"
set "TARGET_BIN=%BUILD_DIR%\forth.bin"
set "MAP_FILE=%BUILD_DIR%\forth.map"

:: --- NETTOYAGE ---
echo === NETTOYAGE ===
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%" >nul && echo [OK] build supprimé
mkdir "%BUILD_DIR%" >nul && echo [OK] build créé

:: --- ASSEMBLAGE ---
echo === ASSEMBLAGE ===
set "obj_list="
for %%s in (boot\*.s kernel\*.s) do (
    set "obj=%BUILD_DIR%\%%~ns.o"
    echo [DEBUG] Assemblage : %%s to !obj!
    "%AS%" -o "!obj!" "%%s" >> "%LOG_FILE%" 2>&1
    if errorlevel 1 (
        echo [ERREUR] %%s
        goto end
    ) else (
        echo [OK] Assemblé : %%s
    )
    set "obj_list=!obj_list! "!obj!""
)

:: --- LINKAGE ---
echo === LINKAGE ===
echo "%LD%" -T "%LINKER%" -nostdlib -Map "%MAP_FILE%" -o "%TARGET_ELF%" !obj_list!
"%LD%" -T "%LINKER%" -nostdlib -Map "%MAP_FILE%" -o "%TARGET_ELF%" !obj_list! >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERREUR] Linkage échoué
    type "%LOG_FILE%"
    pause
    goto end
) else (
    echo [OK] Linkage réussi
    echo [INFO] Map généré : %MAP_FILE%
)

:: --- BIN ---
echo === BIN ===
"%OBJCOPY%" -O binary "%TARGET_ELF%" temp.bin && echo [OK] .elf to temp.bin || goto end

echo [DEBUG] elf2image :
%ESPTOOL% --chip esp32 elf2image --flash_mode=dio --flash_freq=40m --flash_size=4MB -o "%TARGET_BIN%" "%TARGET_ELF%" >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERREUR] elf2image échoué
    echo.
    echo === LOG COMPLET ===
    type "%LOG_FILE%"
    pause
    goto end
) else (
    echo [OK] forth.bin généré
)

del temp.bin 2>nul

echo.
echo === BUILD RÉUSSI : %TARGET_BIN% ===
echo [INFO] Map : %MAP_FILE%
echo [INFO] Log : %LOG_FILE%
goto end

:end
echo.
echo =========================================================
echo     Fin du build - %date% %time%
echo =========================================================
endlocal
:: build.bat - VERSION 1.6.55