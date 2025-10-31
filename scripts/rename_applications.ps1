# Script to rename your Azure AD applications
# This updates both the App Registration and Enterprise Application names

param(
    [Parameter(Mandatory=$true)]
    [string]$ServerAppName,
    
    [Parameter(Mandatory=$true)]
    [string]$ClientAppName
)

$ServerAppId = "68966c19-b05c-4c4d-a4bb-ab7b8e618cac"
$ClientAppId = "9d14b45b-e1d5-4b13-b30c-24cbdd79bc37"

Write-Host "`n=== Renaming Azure AD Applications ===" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
try {
    $null = Get-Command az -ErrorAction Stop
} catch {
    Write-Host "Error: Azure CLI is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Azure CLI: https://aka.ms/installazurecli" -ForegroundColor Yellow
    exit 1
}

# Check if logged in
$account = az account show 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Not logged in to Azure. Please run 'az login' first." -ForegroundColor Red
    exit 1
}

Write-Host "Renaming Server Application..." -ForegroundColor Yellow
Write-Host "  App ID: $ServerAppId" -ForegroundColor Gray
Write-Host "  New Name: $ServerAppName" -ForegroundColor Gray

# Update Server App Registration
Write-Host "  - Updating App Registration..." -ForegroundColor White
az ad app update --id $ServerAppId --display-name "$ServerAppName" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "    [✓] App Registration renamed" -ForegroundColor Green
} else {
    Write-Host "    [✗] Failed to rename App Registration" -ForegroundColor Red
}

# Update Server Service Principal (Enterprise App)
Write-Host "  - Updating Enterprise Application..." -ForegroundColor White
az ad sp update --id $ServerAppId --display-name "$ServerAppName" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "    [✓] Enterprise Application renamed" -ForegroundColor Green
} else {
    Write-Host "    [✗] Failed to rename Enterprise Application" -ForegroundColor Red
}

Write-Host ""
Write-Host "Renaming Client Application..." -ForegroundColor Yellow
Write-Host "  App ID: $ClientAppId" -ForegroundColor Gray
Write-Host "  New Name: $ClientAppName" -ForegroundColor Gray

# Update Client App Registration
Write-Host "  - Updating App Registration..." -ForegroundColor White
az ad app update --id $ClientAppId --display-name "$ClientAppName" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "    [✓] App Registration renamed" -ForegroundColor Green
} else {
    Write-Host "    [✗] Failed to rename App Registration" -ForegroundColor Red
}

# Update Client Service Principal (Enterprise App)
Write-Host "  - Updating Enterprise Application..." -ForegroundColor White
az ad sp update --id $ClientAppId --display-name "$ClientAppName" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "    [✓] Enterprise Application renamed" -ForegroundColor Green
} else {
    Write-Host "    [✗] Failed to rename Enterprise Application" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Cyan
Write-Host "The new names will appear in the Azure Portal and during sign-in." -ForegroundColor White
Write-Host ""


