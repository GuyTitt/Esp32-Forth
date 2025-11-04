
# Utilisation de check_folder

## Description du programme

Le programme **check_folder** permet de vérifier l'existence d'un dossier spécifié en ligne de commande. Il prend en charge des messages personnalisés pour indiquer si un dossier existe ou non, et renvoie un **code de sortie (errorlevel)** qui peut être utilisé pour déterminer l'état de l'existence du dossier.

- **Code de sortie 0** : Le dossier existe.
- **Code de sortie 1** : Le dossier n'existe pas.

## Prérequis

Ce programme est conçu pour fonctionner sur un système Windows. Vous aurez besoin d'un terminal compatible, tel que **CMD** ou **PowerShell**.

## Installation

1. Téléchargez l'exécutable **check_folder.exe**.
2. (Facultatif) Si vous souhaitez recompiler le programme à partir des sources, vous aurez besoin de :
   - **MSYS2** ou un environnement similaire pour Windows.
   - **GCC** et **Make** installés via `pacman`.
   - Le fichier **build.sh** et/ou **Makefile** pour la compilation.

## Exécution du programme

### Syntaxe de base

```bash
check_folder <folder-path> [<message> [<message>]]
````

### Options disponibles :

* `--help`, `-h` : Affiche l'aide (en ligne de commande).
* `--msgOK <msg>`, `-O <msg>` : Message à afficher si le dossier existe (par défaut : message de chemin).
* `--msgNoOK <msg>`, `-N <msg>` : Message à afficher si le dossier n'existe pas (par défaut : message d'erreur).

### Exemples d'utilisation

#### 1. Vérification d'un dossier avec un message personnalisé si le dossier existe :

```bash
check_folder "C:/Program Files" --msgOK "Le dossier existe."
```

#### 2. Vérification d'un dossier avec un message personnalisé si le dossier n'existe pas :

```bash
check_folder "C:/Inexistant" --msgNoOK "Le dossier n'existe pas."
```

#### 3. Vérification sans afficher de message, seulement l'**errorlevel** :

```bash
check_folder "C:/Program Files"
```

Dans ce cas, seul le code de sortie sera utilisé (0 si le dossier existe, 1 si le dossier n'existe pas).

#### 4. Vérification d'un dossier avec un message personnalisé pour les deux cas :

```bash
check_folder "C:/Program Files" --msgOK "Le dossier existe !" --msgNoOK "Le dossier n'existe pas !"
```

### Récupération du code de sortie (errorlevel)

Le programme renvoie un **code de sortie** qui peut être utilisé dans des scripts ou des processus automatisés :

* **0** : Le dossier existe.
* **1** : Le dossier n'existe pas.

Cela permet de traiter cette information dans un environnement de script ou d'automatisation, par exemple avec `CMD` ou `PowerShell`.

#### Exemple dans un script batch :

```batch
check_folder "C:/Program Files"
if %ERRORLEVEL%==0 (
    echo Le dossier existe.
) else (
    echo Le dossier n'existe pas.
)
```

#### Exemple dans PowerShell :

```powershell
./check_folder "C:/Program Files"
if ($LASTEXITCODE -eq 0) {
    Write-Host "Le dossier existe."
} else {
    Write-Host "Le dossier n'existe pas."
}
```

## Version du programme

**Version actuelle** : 1.0.1
---

Projet Existe_Dossier - usage.md