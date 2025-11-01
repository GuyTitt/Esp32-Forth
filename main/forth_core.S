/*****************************************************************************
 * Noyau Forth minimal en assembleur Xtensa LX7 pour ESP32-S3
 * Contient l'entree forth_main_asm et la definition de base d'un mot Forth.
 *****************************************************************************/

    .file "forth_core.S"
    .section .text

    // On declare la fonction globale afin qu'elle puisse etre appelee par le code C (main.c)
    .global forth_main_asm
    .type forth_main_asm, @function

// Definir le registre Forth 'Instruction Pointer' (IP) pour Xtensa
// Xtensa a 64 registres de travail (a0-a63). a2 est souvent utilise pour les retours.
// Nous allons utiliser un registre general (ex: a10) pour simuler le pointeur d'instruction Forth (IP)
#define Forth_IP a10
// Definir le registre Forth 'Data Stack Pointer' (DSP)
#define Forth_DSP a11
// Definir le registre Forth 'Return Stack Pointer' (RSP)
#define Forth_RSP a12

forth_main_asm:
    // Cette routine est l'entree principale. Elle est appelee par app_main en C.
    
    // 1. Initialisation de la pile Xtensa (generalement deja fait par l'IDF)
    // L'ESP-IDF se charge deja de creer la pile du thread, nous ne la touchons pas ici.

    // 2. Initialisation des pointeurs Forth (IP, DSP, RSP)
    // Ces adresses devront pointer vers des zones memoire SRAM allouees pour les piles Forth.
    // Pour l'instant, on les met a 0 pour la demonstration.

    movi    Forth_IP, 0x0   // IP Forth (Adresse de la premiere instruction a executer)
    movi    Forth_DSP, 0x0  // Pointeur de la pile de donnees Forth (Data Stack)
    movi    Forth_RSP, 0x0  // Pointeur de la pile de retour Forth (Return Stack)

    // 3. Initialisation de la console (UART)
    // Normalement fait ici, mais nous allons compter sur l'IDF pour l'instant
    // pour que nous puissions utiliser le printf de debug si besoin, puis optimiser.

    // 4. Boucle principale de l'interpreteur (Outer Interpreter Loop: QUIT/RESTART)
main_loop:
    // Ici, le code Forth devrait:
    // 1. Lire une ligne de l'UART (WAIT FOR INPUT)
    // 2. Parser le mot (TEXT)
    // 3. Chercher le mot dans le dictionnaire (FIND)
    // 4. Compiler ou executer (INTERPRET)
    
    // Exemple d'un mot Forth simple (en attendant d'integrer le vrai dictionnaire)
    call0   WORD_DOT_S // Appeler un mot simple (ex: .S pour afficher la pile)
    
    // Pour une version minimale qui boucle infiniment (essentiel sur un MCU)
    j main_loop
    
    // Note: cette fonction Forth_main_asm ne devrait jamais retourner (r32 est l'adresse de retour Xtensa)

// =================================================================
// 5. Vocabulaire Forth Minimal (Mots Assembleur)
// =================================================================

// Exemple d'un mot Forth tres simple: '.' (Affiche le sommet de la pile DSP)
    .global WORD_DOT
WORD_DOT:
    // ... code pour pop le DSP et afficher la valeur sur l'UART ...
    
    // Pour le moment, une routine de retour simple
    retw.n

// Exemple d'un mot Forth pour empiler la valeur 1 sur le DSP
    .global WORD_ONE
WORD_ONE:
    // (DSP) = (DSP) + 4
    addi    Forth_DSP, Forth_DSP, 4
    // [DSP] = 1
    movi    a3, 1
    s32i    a3, Forth_DSP, 0 // Stocke la valeur dans la memoire pointee par DSP
    
    // Retour du mot Forth (equivalent a NEXT)
    retw.n

// Routine de Test Temporaire
WORD_DOT_S:
    // Affichage d'un message simple via une fonction C (temporaire pour le debogage)
    // Il faudrait idealement appeler une routine en assembleur pur pour l'UART.
    
    // Pour l'instant, nous faisons juste un NOP pour que le code compile
    nop
    retw.n


// Fichier: forth_core.S, Localisation: /main/forth_core.S, Version: 1.0.0
