@description('Location for all resources.')
param location string = resourceGroup().location

@description('Unique name prefix for resources.')
param namePrefix string

@description('Tags for all resources.')
param tags object = {}

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
    skuName: 'S0'
    tags: tags
  }
}

// Configure Azure Function avec les informations Cognitive Services
resource functionAppSettings 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${namePrefix}-function/appsettings'
  properties: {
    'COGNITIVE_SERVICES_ENDPOINT': cognitiveServices.outputs.cognitiveServicesEndpoint
    'COGNITIVE_SERVICES_API_KEY': cognitiveServices.outputs.cognitiveServicesApiKey
  }
}

// Outputs
output functionAppUrl string = functionApp.outputs.functionAppUrl
output cognitiveServicesEndpoint string = cognitiveServices.outputs.cognitiveServicesEndpoint
