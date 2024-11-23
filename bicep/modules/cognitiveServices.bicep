@description('The name of the Cognitive Services account to create (if no existing account is provided).')
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

@description('The name of an existing Cognitive Services account to reuse (optional). If provided, a new account will not be created.')
param existingCognitiveServicesName string = ''

// Création d'un nouveau compte seulement si un compte existant n'est pas fourni
resource cognitiveServicesAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = if (empty(existingCognitiveServicesName)) {
  name: cognitiveServicesName
  location: location
  kind: 'TextAnalytics'
  sku: {
    name: skuName
  }
  tags: tags
}

// Détermine le point de terminaison (nouveau compte ou compte existant)
output cognitiveServicesEndpoint string = empty(existingCognitiveServicesName) ? cognitiveServicesAccount.properties.endpoint : 'https://${existingCognitiveServicesName}.cognitiveservices.azure.com/'

// Détermine l'ID du compte si un nouveau compte est créé
output cognitiveServicesId string = empty(existingCognitiveServicesName) ? cognitiveServicesAccount.id : resourceId('Microsoft.CognitiveServices/accounts', existingCognitiveServicesName)
