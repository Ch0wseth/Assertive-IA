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
  'F0'
  'S0'
])
param skuName string = 'F0' // Default to free tier

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
  name: 'deploy-cognitive-services'
  params: {
    cognitiveServicesName: '${namePrefix}-textanalytics'
    location: location
    skuName: 'F0'
    tags: tags
    existingCognitiveServicesName: existingCognitiveServicesName
  }
}

// Configure Azure Function with Cognitive Services settings
resource functionAppSettings 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${namePrefix}-function/appsettings'
  properties: {
    COGNITIVE_SERVICES_ENDPOINT: cognitiveServices.outputs.cognitiveServicesEndpoint
    COGNITIVE_SERVICES_API_KEY: empty(existingCognitiveServicesName) ? listKeys(resourceId('Microsoft.CognitiveServices/accounts', cognitiveServicesName), '2023-05-01').key1 : '<MANUALLY_PROVIDED_API_KEY>'
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
