/*******************************************************************************
 * Noyau Forth minimal pour ESP32 - Routines en Assembleur Xtensa
 *
 * Ce code implemente les primitives fondamentales et le systeme NEXT.
 *
 * Registres utilises:
 * a2: W - Pointeur de mot (Word pointer, pour le dictionnaire Forth)
 * a3: P - Pointeur de pile de donnees (Data stack pointer, D-Stack)
 * a4: R - Pointeur de pile de retour (Return stack pointer, R-Stack)
 * a5: D - Registre temporaire pour les operations de la D-Stack
 * a15: Registre temporaire general (e.g., pour l'acces UART)
 *******************************************************************************/

    .global forth_init_core
    .global forth_next
    .global forth_exit
    .global forth_main_asm // <<< NOUVEAU: Point d'entree appele par le code C

/*******************************************************************************
 * Adresses et Constantes
 *
 * Definition des adresses physiques de l'UART0 (pour ESP32)
 *******************************************************************************/

.align 4

.set UART_BASE_ADDR, 0x60000000
.set UART_FIFO_ADDR, (UART_BASE_ADDR + 0x0)
.set UART_STATUS_ADDR, (UART_BASE_ADDR + 0x14)
.set MASK_RXFIFO_CNT, 0xFF // Valeur numerique pour les bits 0-7 du FIFO Count

/*******************************************************************************
 * forth_main_asm: Point d'entree principal depuis app_main() en C
 *
 * C'est la fonction qui execute l'initialisation puis entre dans la boucle Forth.
 *******************************************************************************/
forth_main_asm:
    // Initialisation du noyau Forth (initialise a2, a3, a4 dans le code C)
    call0 forth_init_core

    // Saut dans la boucle principale NEXT
    j forth_next


/*******************************************************************************
 * Routine de sortie (temporaire)
 *
 * forth_exit: Fonction appelee par le code C pour terminer (non utilisee pour NEXT)
 *******************************************************************************/
forth_exit:
    ret.n

/*******************************************************************************
 * forth_init_core: Initialisation
 *
 * Le code C initialise les piles P et R, ainsi que le pointeur W.
 *******************************************************************************/
forth_init_core:
    // a2, a3, a4 sont deja charges par le code C
    ret.n

/*******************************************************************************
 * forth_next: Moteur principal du Forth
 *******************************************************************************/
forth_next:
    // 1. Fetch l'adresse du code (CFA) a partir de W (a2)
    l32i a15, a2, 0      // a15 = *W (Code Field Address)

    // 2. Incrementer W pour pointer vers le mot suivant (l'argument)
    addi a2, a2, 4       // W = W + 4 (sizeof(void*))

    // 3. Execution (saut vers le CFA stocke dans a15)
    jx a15               // Saut inconditionnel vers l'adresse du code

// Macros pour manipuler les piles

// PUSH_D: Pousse la valeur dans a5 sur la pile de donnees (D-Stack)
.macro PUSH_D
    addi a3, a3, -4      // P -= 4
    s32i a5, a3, 0       // *P = a5
.endm

// POP_D: Depile la valeur de la D-Stack vers a5
.macro POP_D
    l32i a5, a3, 0       // a5 = *P
    addi a3, a3, 4       // P += 4
.endm

// PUSH_R: Pousse la valeur dans a5 sur la pile de retour (R-Stack)
.macro PUSH_R
    addi a4, a4, -4      // R -= 4
    s32i a5, a4, 0       // *R = a5
.endm

// POP_R: Depile la valeur de la R-Stack vers a5
.macro POP_R
    l32i a5, a4, 0       // a5 = *R
    addi a4, a4, 4       // R += 4
.endm

/*******************************************************************************
 * Primitives Assembleur
 *******************************************************************************/

// DUP: Duplique le sommet de la pile (D-Stack)
.global forth_dup
forth_dup:
    l32i a5, a3, 0
    PUSH_D
    jx a2

// DROP: Retire le sommet de la pile (D-Stack)
.global forth_drop
forth_drop:
    addi a3, a3, 4
    jx a2

// SWAP: Echange les deux elements au sommet de la pile
.global forth_swap
forth_swap:
    l32i a15, a3, 0
    l32i a5, a3, 4
    s32i a5, a3, 0
    s32i a15, a3, 4
    jx a2

// OVER: Copie le deuxieme element au sommet de la pile
.global forth_over
forth_over:
    l32i a5, a3, 4
    PUSH_D
    jx a2

// @ (Fetch): Lit la valeur a l'adresse au sommet de la pile
.global forth_fetch
forth_fetch:
    POP_D
    l32i a5, a5, 0
    PUSH_D
    jx a2

// ! (Store): Ecrit la valeur a l'adresse
.global forth_store
forth_store:
    POP_D
    l32i a15, a3, 0
    s32i a15, a5, 0
    addi a3, a3, 4
    jx a2

// PUSH_R primitive: Pousse a2 (le mot suivant) sur R-stack
.global forth_tor
forth_tor:
    mov a5, a2
    PUSH_R
    jx a2

// POP_R primitive: Recupere le sommet de R-stack vers D-stack
.global forth_fromr
forth_fromr:
    POP_R
    PUSH_D
    jx a2

// QUIT_R: Recupere le sommet de R-stack pour l'execution et change le flux
.global forth_quitr
forth_quitr:
    POP_R
    mov a2, a5
    j forth_next

// UART_RX (Poll): Verifie si un caractere est disponible sur l'UART0
.global forth_uart_rx_poll
forth_uart_rx_poll:
    // 1. Charger l'adresse du registre STATUS (en deux etapes)
    movi a15, UART_STATUS_ADDR           // a15 = adresse absolue
    l32i a15, a15, 0                     // a15 = *adresse (UART_STATUS_REG)

    // 2. Extraire le nombre de caracteres dans le RX_FIFO (bits 0-7)
    movi a14, 0xFF                       // Charger le masque (0xFF) dans un registre temporaire (a14)
    and a15, a15, a14                    // a15 = a15 & a14 (RX_FIFO_CNT). Utilise 'and' (R-R) au lieu de 'andi' (R-I).

    // 3. Tester si le compteur est > 0
    movi a5, 0                           // a5 = 0 (false)
    bnez a15, 1f                         // Si a15 > 0, aller a 1f (true)
    
    // Si RX_FIFO_CNT == 0 (false)
    PUSH_D
    j 2f

1:  // Si RX_FIFO_CNT > 0 (true)
    movi a5, 0xFFFFFFFF                  // a5 = -1 (true)
    PUSH_D
    
2:  // Fin
    jx a2

// UART_RX (Fetch): Lit un caractere du FIFO UART0
.global forth_uart_rx_fetch
forth_uart_rx_fetch:
    // 1. Charger l'adresse du registre FIFO (en deux etapes)
    movi a15, UART_FIFO_ADDR             // a15 = adresse absolue
    l32i a5, a15, 0                      // a5 = *adresse (lit le caractere)

    // 2. Pousse le caractere
    PUSH_D
    jx a2

// UART_TX (Emit): Ecrit le caractere au sommet de la pile vers l'UART0
.global forth_uart_tx_emit
forth_uart_tx_emit:
    POP_D
    
    // 1. Charger l'adresse du registre FIFO (en deux etapes)
    movi a15, UART_FIFO_ADDR               // a15 = adresse absolue
    
    // 2. Ecrire le caractere (a5) dans le registre FIFO
    s32i a5, a15, 0                      // *adresse = a5 (char)
    
    // 3. Continuer
    jx a2

/*******************************************************************************
 * Fin du fichier
 *******************************************************************************/
// Fichier: main/forth_core.S, Version: 2.2
