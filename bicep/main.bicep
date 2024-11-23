@description('Location for all resources.')
param location string = resourceGroup().location

@description('Unique name prefix for resources.')
param namePrefix string

@description('Tags for all resources.')
param tags object = {}

@description('The name of an existing Cognitive Services account (optional).')
param existingCognitiveServicesName string = ''

@description('The name of the Cognitive Services account.')
param cognitiveServicesName string = '${namePrefix}-textanalytics'

@description('The SKU of the Cognitive Services account.')
@allowed([
  'F0' // Free SKU
  'S0' // Standard SKU
])
param skuName string = 'S0' // Default to standard tier

// Création d'un module Function App
module functionApp './modules/functionApp.bicep' = {
  name: '${namePrefix}-functionApp'
  params: {
    functionAppName: '${namePrefix}-function'
    location: location
    appInsightsLocation: location
    tags: tags
  }
}

// Module Cognitive Services
module cognitiveServices './modules/cognitiveServices.bicep' = {
  name: 'deploy-cognitive-services'
  params: {
    cognitiveServicesName: cognitiveServicesName
    location: location
    skuName: skuName
    tags: tags
    existingCognitiveServicesName: existingCognitiveServicesName
  }
}

// Configure Azure Function with Cognitive Services settings
resource functionAppSettings 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${namePrefix}-function/appsettings'
  properties: {
    COGNITIVE_SERVICES_ENDPOINT: cognitiveServices.outputs.cognitiveServicesEndpoint
    // Remplacer la clé API manuellement après le déploiement, ou utiliser un workflow GitHub Actions pour la récupérer.
    COGNITIVE_SERVICES_API_KEY: empty(existingCognitiveServicesName) ? '<API_KEY>' : '<MANUALLY_PROVIDED_API_KEY>'
  }
  dependsOn: [
    functionApp
    cognitiveServices
  ]
}

// Outputs
output functionAppUrl string = functionApp.outputs.functionAppUrl
output cognitiveServicesEndpoint string = cognitiveServices.outputs.cognitiveServicesEndpoint
output cognitiveServicesId string = cognitiveServices.outputs.cognitiveServicesId
