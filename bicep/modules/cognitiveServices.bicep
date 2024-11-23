@description('The name of the Cognitive Services account.')
param cognitiveServicesName string

@description('The location of the Cognitive Services account.')
param location string

@description('The SKU of the Cognitive Services account.')
param skuName string = 'F0' // Free SKU

resource textAnalytics 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: cognitiveServicesName
  location: location
  kind: 'TextAnalytics' // Spécifie le service Text Analytics
  sku: {
    name: skuName
  }
}

output cognitiveServicesEndpoint string = textAnalytics.properties.endpoint
