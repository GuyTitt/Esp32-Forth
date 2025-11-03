/*
 * Application principale C pour l'interprète Forth sur ESP32-S3.
 *
 * Ce fichier gère l'initialisation du matériel (UART) et le point d'entrée
 * de l'application (app_main), qui délègue ensuite le contrôle au noyau Forth
 * en assembleur (forth_core.S).
 *
 * Version: 1.5 (Correction du chemin d'accès dans le commentaire)
 * Localisation : sources/main/main.c
 */

#include <stdio.h>
#include "esp_log.h"
#include "driver/uart.h"

// Déclaration de la fonction d'entrée Forth définie en assembleur (forth_core.S)
void forth_main_asm(void);

// Déclaration des fonctions C externes appelées par l'assembleur Forth
void forth_uart_init(void);
void forth_print_num_c(void);
void forth_print_stack_c(void);
void forth_div_mod_c(void);


/*
 * forth_uart_init()
 * Initialise l'UART0 pour la console série.
 * Cela permet aux mots Forth KEY et EMIT d'interagir avec la console.
 */
void forth_uart_init(void)
{
    const uart_config_t uart_config = {
        .baud_rate = 115200,
        .data_bits = UART_DATA_8_BITS,
        .parity    = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
        .source_clk = UART_SCLK_DEFAULT,
    };

    // Installation du pilote UART avec une file d'attente minimale
    uart_driver_install(UART_NUM_0, 256 * 2, 0, 0, NULL, 0);
    // Configuration des paramètres UART
    uart_param_config(UART_NUM_0, &uart_config);
    // Configuration des broches (ESP32-S3 utilise généralement GPIO43/44 pour la console)
    uart_set_pin(UART_NUM_0,
                 UART_PIN_NO_CHANGE, // TX (GPIO 43 sur S3 par défaut)
                 UART_PIN_NO_CHANGE, // RX (GPIO 44 sur S3 par défaut)
                 UART_PIN_NO_CHANGE, // RTS
                 UART_PIN_NO_CHANGE  // CTS
                 );

    // Affichage d'un message de démarrage basique
    printf("\nESP32-S3 Forth Kernel v0.1\n");
}

/*
 * forth_print_num_c()
 * Placeholder pour le mot Forth '.' (impression de la valeur au sommet de la pile).
 * Nécessite l'accès à la pile DSP qui est gérée par l'assembleur.
 */
void forth_print_num_c(void)
{
    // Ce mot est complexe car il doit lire le DSP, convertir l'entier en chaîne
    // et imprimer sur l'UART. Implémentation détaillée à venir.
    ESP_LOGI("FORTH_STUB", "'.' called. Placeholder.");
    // Retourne l'exécution à NEXT via la pile de retour Forth
}

/*
 * forth_print_stack_c()
 * Placeholder pour le mot Forth '.S' (impression de toute la pile de données).
 */
void forth_print_stack_c(void)
{
    ESP_LOGI("FORTH_STUB", "'.S' called. Placeholder.");
}

/*
 * forth_div_mod_c()
 * Placeholder pour les mots Forth '/' et 'MOD'.
 * Gère la complexité de la division 32-bit signée et le cas d'une division par zéro.
 */
void forth_div_mod_c(void)
{
    // Ce mot devrait analyser le DSP pour déterminer s'il doit effectuer DIV ou MOD
    // et gérer les cas spéciaux.
    ESP_LOGI("FORTH_STUB", "'/' ou 'MOD' appelé. Placeholder.");
}


/*
 * app_main()
 * Fonction principale de l'application ESP-IDF.
 * Elle est le point de départ de l'exécution C après le bootloader.
 */
void app_main(void)
{
    ESP_LOGI("MAIN", "Démarrage de l'interprète Forth pour ESP32-S3.");

    // Le contrôle est passé à la boucle principale Forth
    forth_main_asm();

    // Note: forth_main_asm() ne devrait jamais retourner si le Forth fonctionne correctement.
}
// fichier: sources/main/main.c version 1.5
