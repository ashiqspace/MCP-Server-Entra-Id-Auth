# Deploy Echo MCP Server to Azure App Service
# Target: delete-echo-mcp in tb-PoCHyresAI-euwe-rg-devtst

param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [string]$ResourceGroup = "tb-PoCHyresAI-euwe-rg-devtst",
    [string]$WebAppName = "delete-echo-mcp",
    [string]$ProjectPath = "src/EchoMcpServer.csproj"
)

Write-Host "=== Echo MCP Server Deployment ===" -ForegroundColor Cyan
Write-Host ""

# Set subscription
Write-Host "Setting Azure subscription..." -ForegroundColor Yellow
az account set --subscription $SubscriptionId

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to set subscription. Please check the subscription ID." -ForegroundColor Red
    exit 1
}

Write-Host "Subscription set successfully." -ForegroundColor Green
Write-Host ""

# Verify resource group and web app exist
Write-Host "Verifying resource group and web app..." -ForegroundColor Yellow
$webAppExists = az webapp show --resource-group $ResourceGroup --name $WebAppName 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "Web app '$WebAppName' not found in resource group '$ResourceGroup'." -ForegroundColor Red
    Write-Host "Please verify the web app exists or create it first." -ForegroundColor Red
    exit 1
}

Write-Host "Web app found successfully." -ForegroundColor Green
Write-Host ""

# Build the application
Write-Host "Building the application..." -ForegroundColor Yellow
dotnet publish $ProjectPath -c Release -o publish

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed." -ForegroundColor Red
    exit 1
}

Write-Host "Build completed successfully." -ForegroundColor Green
Write-Host ""

# Create deployment package
Write-Host "Creating deployment package..." -ForegroundColor Yellow
if (Test-Path "publish.zip") {
    Remove-Item "publish.zip" -Force
}

Compress-Archive -Path "publish\*" -DestinationPath "publish.zip" -Force

Write-Host "Deployment package created." -ForegroundColor Green
Write-Host ""

# Deploy to Azure
Write-Host "Deploying to Azure Web App '$WebAppName'..." -ForegroundColor Yellow
az webapp deploy `
    --resource-group $ResourceGroup `
    --name $WebAppName `
    --src-path "publish.zip" `
    --type zip `
    --async false

if ($LASTEXITCODE -ne 0) {
    Write-Host "Deployment failed." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Deployment Completed Successfully ===" -ForegroundColor Green
Write-Host ""
Write-Host "Web App URL: https://$WebAppName.azurewebsites.net/mcp" -ForegroundColor Cyan
Write-Host ""
Write-Host "To view logs, run:" -ForegroundColor Yellow
Write-Host "az webapp log tail --resource-group $ResourceGroup --name $WebAppName" -ForegroundColor White
