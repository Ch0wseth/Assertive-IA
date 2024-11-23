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

// Outputs
output functionAppUrl string = functionApp.outputs.functionAppUrl
output storageAccountName string = functionApp.outputs.storageAccountName
output appInsightsInstrumentationKey string = functionApp.outputs.appInsightsInstrumentationKey
