// Le systeme de compilation ESP-IDF requiert un main.c ou un fichier similaire
// definissant l'entree du programme. Nous le gardons minimaliste.

// Declaration externe de la fonction d'entree Forth ecrite en assembleur
// Cette fonction est definie dans forth_core.S
extern void forth_main_asm(void);

// L'ESP-IDF (ou FreeRTOS en dessous) commence l'execution dans cette fonction.
void app_main(void)
{
    // L'ESP-IDF a deja fait l'initialisation de la memoire (BSS, Data) et du RTOS.

    // Appel direct de la routine Forth ecrite en assembleur
    // Cette fonction contient la boucle de l'interpreteur Forth et ne devrait jamais retourner.
    forth_main_asm();
}

// Fichier: main.c, Localisation: /main/main.c, Version: 1.0.0
