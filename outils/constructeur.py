# Fichier: outils/constructeur.py, Version: 1.0
#
# Orchestrateur de construction en Python pour le projet ESP-Forth.
# Ce script est appele par outils/lanceur.bat apres l'initialisation de l'environnement IDF.
# Il gere le nettoyage, la configuration (set-target), la compilation (build)
# et la post-compilation (creation du fichier UF2).

import os
import sys
import subprocess
from datetime import datetime

# --- Configuration du Projet ---
VERSION_CONSTRUCTION = "1.0"
PROJECT_DIR = "sources"
TARGET_DEVICE = "esp32s3"
BUILD_DIR = os.path.join(PROJECT_DIR, "build")
BIN_FILE = os.path.join(BUILD_DIR, "forth_interpreter.bin")
UF2_FILE = os.path.join("cible", "firmware_forth.uf2")
LOG_DIR = os.path.join(BUILD_DIR, "log")
VERSION_LOG_FILE = os.path.join(LOG_DIR, "build.log")
REQUIRED_IDF_PATH = os.environ.get('IDF_PATH')

# --- Fonctions Utilitaires ---

def log_message(message: str, is_error: bool = False, to_console: bool = True):
    """Ecrit un message dans le fichier de log et optionnellement dans la console."""
    timestamp = datetime.now().strftime("[%H:%M:%S]")
    
    # Formatage du message pour le log
    log_line = f"{timestamp} {message}"
    
    try:
        with open(VERSION_LOG_FILE, 'a', encoding='utf-8') as f:
            f.write(log_line + "\n")
    except Exception as e:
        # En cas d'echec de l'ecriture du log, on imprime au moins a la console
        print(f"Erreur d'ecriture du log: {e}", file=sys.stderr)

    # Impression a la console
    if to_console:
        if is_error:
            print(f"[ERREUR] {message}", file=sys.stderr)
        else:
            print(f"[INFO] {message}")

def run_command(command_list: list, log_output: bool = True) -> subprocess.CompletedProcess:
    """Execute une commande systeme et journalise l'entree/sortie."""
    
    cmd_str = ' '.join(command_list)
    log_message(f"EXECUTION COMMANDE: {cmd_str}")
    
    # Execution de la commande
    try:
        result = subprocess.run(
            command_list,
            check=False,
            capture_output=True,
            text=True,
            encoding='utf-8'
        )
    except FileNotFoundError:
        log_message(f"**ERREUR:** Commande non trouvee. Verifiez votre PATH.", is_error=True)
        # Retourne un objet simule d'echec pour la verification
        return subprocess.CompletedProcess(command_list, 1, stdout="", stderr="Command not found.")

    # Journalisation de la sortie complete (stdout et stderr)
    if log_output:
        log_message(f"--- STDOUT ---\n{result.stdout}")
        log_message(f"--- STDERR ---\n{result.stderr}")
        
    if result.returncode != 0:
        log_message(f"ECHEC (Code {result.returncode}) de la commande: {cmd_str}", is_error=True)

    return result

# --- Fonction Principale ---

def main():
    print("--------------------------------------------------------------------------------")
    print(f"[ETAPE 1] Orchestrateur de Construction Python V {VERSION_CONSTRUCTION}")
    print("--------------------------------------------------------------------------------")
    
    # 1. Verification de l'environnement IDF
    if not REQUIRED_IDF_PATH:
        print("\n**ERREUR CRITIQUE: La variable d'environnement IDF_PATH n'est pas definie.**", file=sys.stderr)
        print("Veuillez executer outils\\lanceur.bat avant ce script.", file=sys.stderr)
        return 1

    # 2. Preparation des repertoires et du fichier de log
    os.makedirs(LOG_DIR, exist_ok=True)
    os.makedirs("cible", exist_ok=True)
    
    # Initialisation du log
    with open(VERSION_LOG_FILE, 'w', encoding='utf-8') as f:
        f.write("------------------------------------------------------------\n")
        f.write(f"Log de Construction Forth - Version {VERSION_CONSTRUCTION} (Python)\n")
        f.write(f"Date : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write("------------------------------------------------------------\n")
        
    log_message(f"[INFO] IDF_PATH detecte: {REQUIRED_IDF_PATH}")
    log_message(f"[INFO] Cible de construction: {TARGET_DEVICE}")

    # 3. Nettoyage Complet (fullclean)
    log_message("\n[ETAPE 2] Nettoyage (idf.py fullclean)")
    clean_cmd = ['idf.py', 'fullclean', '--project-dir', PROJECT_DIR]
    
    result_clean = run_command(clean_cmd)
    
    if result_clean.returncode != 0:
        log_message("**ECHEC du nettoyage idf.py fullclean.**", is_error=True)
        # Tenter un nettoyage manuel du build pour etre sur
        if os.path.exists(BUILD_DIR):
            os.system(f'rmdir /s /q "{BUILD_DIR}"')
            log_message("Nettoyage manuel du repertoire build effectue.")
        return 2

    if os.path.exists(BUILD_DIR):
        os.system(f'rmdir /s /q "{BUILD_DIR}"')
        log_message("Nettoyage manuel du repertoire build effectue.")
    
    # 4. Configuration de la Cible (set-target)
    log_message("\n[ETAPE 3] Configuration de la Cible (idf.py set-target)")
    set_target_cmd = ['idf.py', 'set-target', TARGET_DEVICE, '--project-dir', PROJECT_DIR]
    
    result_target = run_command(set_target_cmd)
    if result_target.returncode != 0:
        log_message(f"**ERREUR idf.py set-target {TARGET_DEVICE}**", is_error=True)
        return 3

    # 5. Compilation (build)
    log_message("\n[ETAPE 4] Lancement de la Compilation (idf.py build)")
    build_cmd = ['idf.py', 'build', '--project-dir', PROJECT_DIR]
    
    result_build = run_command(build_cmd, log_output=False) # Supprime la sortie console, trop verbeuse
    
    if result_build.returncode != 0:
        log_message("**ECHEC de la compilation idf.py build.**", is_error=True)
        print("\n\n**************************************************************")
        print("**ECHEC DE LA COMPILATION. Consultez le fichier build.log.**")
        print("**************************************************************", file=sys.stderr)
        return 4
    
    log_message("[SUCCES] Compilation terminee.")

    # 6. Creation du Firmware UF2
    log_message("\n[ETAPE 5] Creation du Firmware UF2")

    if os.path.exists(BIN_FILE):
        log_message("Binaire trouve: Conversion en UF2...")
        
        # Le script mkuf2.py doit etre appele avec 'python' car c'est un script.
        # Le chemin de python doit etre defini dans PATH par export.bat.
        uf2_cmd = [
            'python',
            'outils/mkuf2.py',  # Chemin relatif au repertoire racine du projet
            '--input', BIN_FILE,
            '--output', UF2_FILE
        ]
        
        result_uf2 = run_command(uf2_cmd)
        if result_uf2.returncode != 0:
            log_message("**ERREUR lors de la creation de l'UF2 via mkuf2.py.**", is_error=True)
            return 5
        
        log_message(f"[SUCCES] Fichier UF2 genere: {UF2_FILE}")
        print("\n***************************************************************")
        print(f"SUCCES TOTAL! Le firmware UF2 est pret: {UF2_FILE}")
        print("***************************************************************")
        
    else:
        log_message(f"**ERREUR: Binaire de l'application non trouve : {BIN_FILE}**", is_error=True)
        return 6
    
    log_message("\n------------------------------------------------------------")
    log_message("Construction terminee avec succes (Code 0)")
    log_message("------------------------------------------------------------")
    return 0

if __name__ == "__main__":
    sys.exit(main())

# Fichier: outils/constructeur.py, Version: 1.0
