@description('The name of the Web App (existing)')
param webAppName string = 'delete-echo-mcp'

@description('Location for all resources')
param location string = resourceGroup().location

// Note: This bicep is simplified since we're deploying to an existing Web App
// No infrastructure changes needed - we'll just deploy the code using Azure CLI

@description('The Web App resource ID for reference')
output webAppName string = webAppName

@description('Deployment info')
output message string = 'Use Azure CLI to deploy the application code to the existing Web App'
