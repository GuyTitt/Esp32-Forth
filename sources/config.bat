:: Configuration des chemins de l'environnement ESP-IDF
:: Ce fichier doit etre personnalise selon votre installation locale.

:: 1. Chemin vers la racine du repertoire esp-idf (ex: esp-idf-v5.5.1)
set IDF_PATH=C:\Espressif\frameworks\frameworks\esp-idf-v5.5.1

:: 2. Chemin complet vers le script 'export.bat' de l'IDF
set IDF_EXPORT_SCRIPT=%IDF_PATH%\export.bat

:: 3. Chemin vers le repertoire racine de l'environnement virtuel Python (VENV)
:: C'est le chemin qui contient le sous-dossier "\Scripts".
set IDF_PYTHON_VENV=C:\Espressif\frameworks\python_env\idf5.5_py3.11_env

:: Fichier: sources\config.bat, Version: 1.1