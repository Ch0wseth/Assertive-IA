@description('Location for all resources.')
param location string = resourceGroup().location

@description('Unique name prefix for resources.')
param namePrefix string

module functionApp './modules/functionApp.bicep' = {
  name: '${namePrefix}-functionApp'
  params: {
    functionAppName: namePrefix
    location: location
    appInsightsLocation: location
  }
}

module cognitiveServices './modules/cognitiveServices.bicep' = {
  name: '${namePrefix}-text-analytics'
  params: {
    cognitiveServicesName: '${namePrefix}-textanalytics'
    location: location
  }
}

// Outputs
output functionAppUrl string = functionApp.outputs.functionAppUrl
output storageAccountName string = functionApp.outputs.storageAccountName
output appInsightsInstrumentationKey string = functionApp.outputs.appInsightsInstrumentationKey
output cognitiveServicesEndpoint string = cognitiveServices.outputs.cognitiveServicesEndpoint
