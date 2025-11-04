# Fichier: outils/mkuf2.py, Version: 1.0
#
# Utilitaire minimaliste pour creer un fichier UF2 a partir d'un binaire d'application
# pour les appareils ESP32-S3.
#
# Syntaxe d'appel: python mkuf2.py --input <chemin/vers/app.bin> --output <chemin/vers/firmware.uf2>

import struct
import sys
import argparse
import os

# --- Constantes UF2 ---
UF2_MAGIC_START0 = 0x0A324655 # UF2
UF2_MAGIC_START1 = 0x979A466A # DÉBUT du second magic number
UF2_MAGIC_END = 0xFA570001    # FIN du second magic number

# Flags UF2: 0x2000 indique un 'chain-linked segment' (utile pour ESP32)
UF2_FLAG_APP_IMAGE = 0x2000 
UF2_PAYLOAD_SIZE = 256      # Taille des donnees utiles par bloc UF2 (256 octets)
UF2_BLOCK_SIZE = 512        # Taille totale d'un bloc UF2

# Adresse de debut de l'application ESP32-S3 par defaut dans la memoire flash
APP_START_ADDRESS = 0x10000 

# --- Fonction principale ---

def create_uf2(input_path: str, output_path: str) -> int:
    """Cree un fichier UF2 a partir d'un binaire brut."""
    
    # 1. Verification et lecture du binaire d'entree
    if not os.path.exists(input_path):
        print(f"Erreur: Le fichier d'entree binaire n'existe pas: {input_path}", file=sys.stderr)
        return 1

    try:
        with open(input_path, 'rb') as f:
            binary_data = f.read()
    except IOError as e:
        print(f"Erreur de lecture du fichier binaire: {e}", file=sys.stderr)
        return 1

    binary_size = len(binary_data)
    # Calcul du nombre total de blocs UF2 necessaires
    num_blocks = (binary_size + UF2_PAYLOAD_SIZE - 1) // UF2_PAYLOAD_SIZE
    
    print(f"[MKUF2] Taille du binaire: {binary_size} octets. Generation de {num_blocks} blocs UF2.")
    
    # 2. Preparation des donnees UF2
    uf2_blocks = []
    current_addr = APP_START_ADDRESS
    
    for block_i in range(num_blocks):
        offset = block_i * UF2_PAYLOAD_SIZE
        payload = binary_data[offset : offset + UF2_PAYLOAD_SIZE]
        payload_size = len(payload)
        
        # Creation de l'entete du bloc (32 octets)
        # Le format '<I' signifie entier non signe de 4 octets (32-bit), petit-boutiste (little-endian)
        header = struct.pack(
            '<IIIIIIII',
            UF2_MAGIC_START0,       # Magic 0 (0-3)
            UF2_MAGIC_START1,       # Magic 1 (4-7)
            UF2_FLAG_APP_IMAGE,     # Flags (8-11)
            current_addr,           # Adresse memoire cible (12-15)
            payload_size,           # Taille de la charge utile (16-19)
            block_i,                # Numero du bloc (20-23)
            num_blocks,             # Nombre total de blocs (24-27)
            0x48FF6239              # ID de la carte (custom ESP32) (28-31)
        )
        
        block_data = header + payload
        
        # Remplissage (padding) jusqu'a 508 octets
        padding_size = UF2_BLOCK_SIZE - len(block_data) - 4 # -4 pour le magic end
        block_data += b'\x00' * padding_size
        
        # Ajout du magic end (les 4 derniers octets)
        block_data += struct.pack('<I', UF2_MAGIC_END)
        
        # Verification de la taille finale
        if len(block_data) != UF2_BLOCK_SIZE:
            print(f"Erreur interne: Taille de bloc UF2 incorrecte ({len(block_data)} octets)", file=sys.stderr)
            return 1

        uf2_blocks.append(block_data)
        current_addr += UF2_PAYLOAD_SIZE
        
    # 3. Ecriture du fichier UF2
    try:
        with open(output_path, 'wb') as f:
            for block in uf2_blocks:
                f.write(block)
        print(f"[MKUF2] Succes: Fichier UF2 cree: {output_path}")
    except IOError as e:
        print(f"Erreur d'ecriture du fichier UF2: {e}", file=sys.stderr)
        return 1

    return 0

# --- Point d'entree de l'outil ---

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Utilitaire minimaliste de creation de fichier UF2 pour ESP32 a partir d'un binaire d'application."
    )
    parser.add_argument(
        '--input', 
        type=str, 
        required=True, 
        help="Chemin vers le fichier binaire d'entree (.bin)."
    )
    parser.add_argument(
        '--output', 
        type=str, 
        required=True, 
        help="Chemin vers le fichier UF2 de sortie (.uf2)."
    )
    
    args = parser.parse_args()
    
    sys.exit(create_uf2(args.input, args.output))

# Fichier: outils/mkuf2.py, Version: 1.0
