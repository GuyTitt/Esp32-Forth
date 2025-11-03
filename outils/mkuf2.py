import argparse
import sys
import os
import subprocess

# --- Configuration et Logging ---
UF2_COMPONENT_PATH = os.path.join(os.environ.get('IDF_PATH', ''), 'components', 'uf2')
MKUF2_SCRIPT = os.path.join(UF2_COMPONENT_PATH, 'mkuf2.py')

def log_error(msg):
    """Affiche un message d'erreur."""
    print(f"[ERREUR] {msg}", file=sys.stderr)

def log_info(msg):
    """Affiche un message d'information."""
    print(f"[INFO] {msg}")

def main():
    """Fonction principale pour la creation du fichier UF2."""
    parser = argparse.ArgumentParser(description="Convertit un binaire ESP32-S3 en format UF2.")
    parser.add_argument("--input", required=True, help="Chemin du fichier binaire (.bin) a convertir.")
    parser.add_argument("--output", required=True, help="Chemin du fichier de sortie (.uf2).")
    
    args = parser.parse_args()
    
    input_file = args.input
    output_file = args.output
    
    if not os.path.exists(input_file):
        log_error(f"Fichier d'entree non trouve: {input_file}")
        sys.exit(1)

    # Assurez-vous que IDF_PATH est defini et que le script mkuf2.py d'ESP-IDF existe
    if not os.environ.get('IDF_PATH'):
        log_error("La variable d'environnement IDF_PATH n'est pas definie.")
        sys.exit(1)
        
    if not os.path.exists(MKUF2_SCRIPT):
        log_error(f"Script mkuf2.py non trouve dans IDF_PATH. Verifiez votre installation ESP-IDF. Chemin attendu: {MKUF2_SCRIPT}")
        sys.exit(1)

    # 1. Recuperer le nom du projet a partir du chemin du binaire
    # Ex: sources/build/forth_interpreter.bin -> forth_interpreter
    project_name = os.path.basename(input_file).replace('.bin', '')
    
    # 2. Construction de la commande
    # Syntaxe : python mkuf2.py write --project-name [NAME] -o [OUT_FILE] [IN_FILE]
    command = [
        sys.executable,  # Utilise l'interpreteur Python courant
        MKUF2_SCRIPT,
        "write",
        "--project-name", project_name,
        "-o", output_file,
        input_file
    ]
    
    log_info(f"Lancement de la creation UF2 avec: {' '.join(command)}")

    # 3. Execution de la commande
    try:
        process = subprocess.run(command, check=True, capture_output=True, text=True, encoding='utf-8')
        log_info("UF2 cree avec succes.")
        log_info(f"Sortie: {process.stdout.strip()}")
        sys.exit(0)
    except subprocess.CalledProcessError as e:
        log_error(f"Echec de la creation de l'UF2. Code de retour: {e.returncode}")
        log_error(f"Stderr: {e.stderr.strip()}")
        sys.exit(1)
    except FileNotFoundError:
        log_error(f"Le script Python ou {MKUF2_SCRIPT} n'a pas pu etre execute.")
        sys.exit(1)

if __name__ == "__main__":
    main()

# Fichier: outils/mkuf2.py, Version: 1.0
