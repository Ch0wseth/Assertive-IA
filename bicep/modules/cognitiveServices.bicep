@description('The name of the Cognitive Services account.')
param cognitiveServicesName string

@description('The location of the Cognitive Services account.')
param location string

@description('The SKU of the Cognitive Services account.')
param skuName string = 'F0' // Free SKU

resource cognitiveServicesAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: cognitiveServicesName
  location: location
  kind: 'CognitiveServices'
  sku: {
    name: skuName
  }
  properties: {
    apiProperties: {
      disableLocalAuth: false
    }
  }
}

output cognitiveServicesEndpoint string = cognitiveServicesAccount.properties.endpoint
output cognitiveServicesApiKey string = listKeys(cognitiveServicesAccount.id, '2023-05-01').key1
