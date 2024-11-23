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

@description('The name of the existing Cognitive Services account (optional).')
param existingCognitiveServicesName string = ''

resource cognitiveServicesAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = if (empty(existingCognitiveServicesName)) {
  name: cognitiveServicesName
  location: location
  kind: 'TextAnalytics'
  sku: {
    name: skuName
  }
  tags: tags
}

output cognitiveServicesEndpoint string = empty(existingCognitiveServicesName) ? cognitiveServicesAccount.properties.endpoint : 'https://{existingCognitiveServicesName}.cognitiveservices.azure.com/'
output cognitiveServicesApiKey string = empty(existingCognitiveServicesName) ? listKeys(cognitiveServicesAccount.id, '2023-05-01').key1 : ''
