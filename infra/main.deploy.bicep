targetScope = 'subscription'

@description('The name of the resource group')
param resourceGroupName string = 'tb-PoCHyresAI-euwe-rg-devtst'

@description('Location for all resources')
param location string = deployment().location

@description('The SKU of App Service Plan')
@allowed([
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1v2'
  'P2v2'
  'P3v2'
  'P1v3'
  'P2v3'
  'P3v3'
])
param sku string = 'B1'

// Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

// Deploy main resources
module main 'main.bicep' = {
  name: 'mainDeployment'
  scope: rg
  params: {
    location: location
    sku: sku
  }
}

@description('The resource group name')
output resourceGroupName string = rg.name

@description('The App Service Plan resource ID')
output appServicePlanId string = main.outputs.appServicePlanId

@description('The Web App resource ID')
output webAppId string = main.outputs.webAppId

@description('The Web App default hostname')
output webAppHostName string = main.outputs.webAppHostName

@description('The Web App name')
output webAppName string = main.outputs.webAppName
