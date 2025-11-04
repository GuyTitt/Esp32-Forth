# Fichier outils/lanceur.ps1 version 1.1 (Renommé pour homogénéité)
# Lanceur pour PowerShell 7 (ou Core)

# Configuration
$VERSION_CONSTRUCTEUR_PS = "1.1"

# Efface la console
Clear-Host

Write-Host "--------------------------------------------------------------------------------"
Write-Host "[ETAPE 0] LANCEUR DE CONSTRUCTION ESP-FORTH V $VERSION_CONSTRUCTEUR_PS"
Write-Host "          (Démarre l'orchestrateur Python)"
Write-Host "--------------------------------------------------------------------------------"

# Vérification de IDF_PATH (nécessaire pour le script Python)
if (-not (Get-Item Env:IDF_PATH -ErrorAction SilentlyContinue)) {
    Write-Error "**ERREUR: La variable d'environnement IDF_PATH n'est pas définie.**"
    Write-Host "Veuillez exécuter export.ps1 ou export.bat dans le répertoire d'installation de l'ESP-IDF."
    exit 1
}

Write-Host "Lancement de outils\constructeur.py..."
Write-Host "--------------------------------------------------------------------------------"

# Lancement du script Python
# Le script Python gère maintenant toute la logique de build, de log, et le 'Tee-like' streaming
python .\outils\constructeur.py

# Vérification du code de retour du script Python
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n****" -ForegroundColor Red
    Write-Host "** Echec de la construction. **" -ForegroundColor Red
    Write-Host "****" -ForegroundColor Red
    exit 1
}

Write-Host "`n****" -ForegroundColor Green
Write-Host "Succès : La construction a été terminée par outils\constructeur.py." -ForegroundColor Green
Write-Host "****" -ForegroundColor Green

# Fin du script
exit 0

# Fichier outils/lanceur.ps1 version 1.1
