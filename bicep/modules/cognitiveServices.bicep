@description('The name of the Cognitive Services account.')
param cognitiveServicesName string

@description('The location of the Cognitive Services account.')
param location string

@description('The SKU of the Cognitive Services account.')
@allowed([
  'F0' // Free SKU
  'S0' // Standard SKU
])
param skuName string

@description('Optional tags for the resource.')
param tags object = {}

resource cognitiveServicesAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: cognitiveServicesName
  location: location
  kind: 'TextAnalytics'
  sku: {
    name: skuName
  }
  tags: tags
}

output cognitiveServicesEndpoint string = cognitiveServicesAccount.properties.endpoint
output cognitiveServicesApiKey string = listKeys(cognitiveServicesAccount.id, '2023-05-01').key1
