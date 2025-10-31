# Script to check if "Assignment Required" is enabled for your Entra ID applications
# This checks the appRoleAssignmentRequired property on the Service Principal (Enterprise Application)

param(
    [string]$ServerAppId = "",
    [string]$ClientAppId = ""
)

Write-Host "Checking 'Assignment Required' setting for your applications..." -ForegroundColor Cyan
Write-Host ""

# Get app IDs from environment if not provided
if ([string]::IsNullOrEmpty($ServerAppId)) {
    $ServerAppId = $env:AZURE_SERVER_APP_ID
}
if ([string]::IsNullOrEmpty($ClientAppId)) {
    $ClientAppId = $env:AZURE_CLIENT_APP_ID
}

if ([string]::IsNullOrEmpty($ServerAppId) -or [string]::IsNullOrEmpty($ClientAppId)) {
    Write-Host "Error: Could not find application IDs. Please set environment variables or pass as parameters." -ForegroundColor Red
    Write-Host "Usage: .\check_assignment_required.ps1 -ServerAppId <id> -ClientAppId <id>" -ForegroundColor Yellow
    exit 1
}

Write-Host "Server App ID: $ServerAppId" -ForegroundColor White
Write-Host "Client App ID: $ClientAppId" -ForegroundColor White
Write-Host ""

# Function to check assignment required using Azure CLI
function Check-AssignmentRequired {
    param([string]$AppId, [string]$AppName)
    
    Write-Host "Checking $AppName..." -ForegroundColor Yellow
    
    try {
        # Get the service principal (Enterprise Application) for this app
        $sp = az ad sp list --filter "appId eq '$AppId'" --query "[0]" 2>$null | ConvertFrom-Json
        
        if ($null -eq $sp) {
            Write-Host "  [WARNING] Service Principal not found for App ID: $AppId" -ForegroundColor Red
            Write-Host "  This application may not be registered in your tenant yet." -ForegroundColor Red
            return
        }
        
        $spId = $sp.id
        $displayName = $sp.displayName
        
        # Get the appRoleAssignmentRequired property
        $assignmentRequired = $sp.appRoleAssignmentRequired
        
        Write-Host "  Display Name: $displayName" -ForegroundColor Gray
        Write-Host "  Service Principal ID: $spId" -ForegroundColor Gray
        
        if ($assignmentRequired -eq $true) {
            Write-Host "  [✓] Assignment Required: ENABLED" -ForegroundColor Green
            Write-Host "      Users MUST be assigned to access this application" -ForegroundColor Green
        } else {
            Write-Host "  [✗] Assignment Required: DISABLED" -ForegroundColor Red
            Write-Host "      ALL users in your tenant can access this application" -ForegroundColor Red
        }
        
        # Get assigned users count
        $assignments = az ad app permission list --id $AppId 2>$null | ConvertFrom-Json
        Write-Host ""
        
    } catch {
        Write-Host "  [ERROR] Failed to check: $_" -ForegroundColor Red
    }
}

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

Write-Host "=== Checking Server Application ===" -ForegroundColor Cyan
Check-AssignmentRequired -AppId $ServerAppId -AppName "Server App"

Write-Host ""
Write-Host "=== Checking Client Application ===" -ForegroundColor Cyan
Check-AssignmentRequired -AppId $ClientAppId -AppName "Client App"

Write-Host ""
Write-Host "=== Recommendations ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "To ENABLE 'Assignment Required' (recommended for blocking users):" -ForegroundColor Yellow
Write-Host "  1. Go to: https://portal.azure.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview" -ForegroundColor White
Write-Host "  2. Search for your application by name or ID" -ForegroundColor White
Write-Host "  3. Click on the application" -ForegroundColor White
Write-Host "  4. Go to 'Properties'" -ForegroundColor White
Write-Host "  5. Set 'Assignment required?' to 'Yes'" -ForegroundColor White
Write-Host "  6. Click 'Save'" -ForegroundColor White
Write-Host ""
Write-Host "Alternatively, use this command:" -ForegroundColor Yellow
Write-Host "  az ad sp update --id `<service-principal-id`> --set appRoleAssignmentRequired=true" -ForegroundColor Cyan
Write-Host ""
Write-Host "To assign users/groups after enabling:" -ForegroundColor Yellow
Write-Host "  Go to 'Users and groups' section in the Enterprise Application" -ForegroundColor White
Write-Host "  Click 'Add user/group' and assign who should have access" -ForegroundColor White

