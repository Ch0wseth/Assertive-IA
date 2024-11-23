@description('Location for all resources.')
param location string = resourceGroup().location

@description('Unique name prefix for resources.')
param namePrefix string

@description('Tags for all resources.')
param tags object = {}

@description('The name of an existing Cognitive Services account (optional).')
param existingCognitiveServicesName string = ''

module functionApp './modules/functionApp.bicep' = {
  name: '${namePrefix}-functionApp'
  params: {
    functionAppName: '${namePrefix}-function'
    location: location
    appInsightsLocation: location
    tags: tags
  }
}

module cognitiveServices './modules/cognitiveServices.bicep' = {
  name: '${namePrefix}-text-analytics'
  params: {
    cognitiveServicesName: '${namePrefix}-textanalytics'
    location: location
    skuName: 'F0' // Default to free tier
    tags: tags
    existingCognitiveServicesName: existingCognitiveServicesName
  }
}

// Configure Azure Function with Cognitive Services settings
resource functionAppSettings 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${namePrefix}-function/appsettings' // Use static name instead of dynamic outputs
  properties: {
    COGNITIVE_SERVICES_ENDPOINT: cognitiveServices.outputs.cognitiveServicesEndpoint
    COGNITIVE_SERVICES_API_KEY: empty(existingCognitiveServicesName) ? listKeys(resourceId('Microsoft.CognitiveServices/accounts', cognitiveServices.name), '2023-05-01').key1 : '<MANUALLY_PROVIDED_API_KEY>'
  }
  dependsOn: [
    functionApp
    cognitiveServices
  ]
}

// Outputs
output functionAppUrl string = functionApp.outputs.functionAppUrl
output cognitiveServicesEndpoint string = cognitiveServices.outputs.cognitiveServicesEndpoint
