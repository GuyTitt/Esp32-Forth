@echo off

:: Fichier: sources/config.bat, Version: 1.5
:: Objectif: Definir les chemins d'acces pour l'environnement ESP-IDF.
:: NOTE: setlocal/endlocal ont ete retires pour garantir le retour des variables.

:: =================================================================
:: DEFINISSEZ LES CHEMINS D'INSTALLATION ESPRESSIF CI-DESSOUS
:: =================================================================

:: 1. Chemin racine des outils IDF (Utilise par lanceur.cmd pour trouver export.bat)
set IDF_TOOLS_PATH=C:\Espressif\frameworks
:: 2. Chemin vers le dossier racine de l'IDF (pour les autres outils)
set IDF_PATH=C:\Espressif\frameworks\esp-idf-v5.5.1
:: 3. Definir le script d'export IDF
set IDF_EXPORT_SCRIPT=%IDF_PATH%\export.bat
:: Affichage de l'information (Nous nous fions au lanceur.cmd pour l'affichage detaille)
echo [INFO] IDF_EXPORT_SCRIPT défini: %IDF_EXPORT_SCRIPT%
echo [INFO] IDF_TOOLS_PATH défini: %IDF_TOOLS_PATH%


:: Fichier: sources/config.bat, Version: 1.5
