@echo off
setlocal

set line=---------------------------------------------------
set title=Verification des Versions des Outils
set header=^| Outil         ^| Version installee
set separator=^|---------------^|-------------------
set python_version=N/A
set idf_version=N/A
set git_version=N/A
set cmake_version=N/A
set ninja_version=N/A

echo.
echo %title%
echo %line%

:: ---------------------------------
:: 1. Version Python (pip)
:: ---------------------------------
for /f "tokens=*" %%a in ('python -V 2^>^&1') do set python_version=%%a
set python_version=%python_version:Python =%
if "%python_version%"=="" set python_version=ERREUR - Absent du PATH

:: ---------------------------------
:: 2. Version ESP-IDF (via git)
:: ---------------------------------
pushd "%IDF_PATH%"
for /f "tokens=*" %%a in ('git describe --tags --always 2^>^&1') do set idf_version=%%a
popd
if "%idf_version%"=="" set idf_version=ERREUR - Git non disponible ou chemin incorrect

:: ---------------------------------
:: 3. Version Git
:: ---------------------------------
for /f "tokens=3" %%a in ('git --version 2^>^&1') do set git_version=%%a
if "%git_version%"=="" set git_version=ERREUR - Non trouve

:: ---------------------------------
:: 4. Version CMake
:: ---------------------------------
for /f "tokens=3" %%a in ('cmake --version ^| findstr /i "version"') do set cmake_version=%%a
if "%cmake_version%"=="" set cmake_version=ERREUR - Non trouve

:: ---------------------------------
:: 5. Version Ninja
:: ---------------------------------
for /f "tokens=3" %%a in ('ninja --version 2^>^&1') do set ninja_version=%%a
if "%ninja_version%"=="" set ninja_version=ERREUR - Non trouve


:: ---------------------------------
:: Affichage du Tableau
:: ---------------------------------
echo %header%
echo %separator%
echo ^| IDF_PATH      ^| %IDF_PATH%
echo ^| IDF Version   ^| %idf_version%
echo %separator%
echo ^| Python        ^| %python_version%
echo ^| Git           ^| %git_version%
echo ^| CMake         ^| %cmake_version%
echo ^| Ninja         ^| %ninja_version%
echo %line%
echo.

endlocal
exit /b 0

:: Fichier: outils\version_check.bat, Version: 1.0
