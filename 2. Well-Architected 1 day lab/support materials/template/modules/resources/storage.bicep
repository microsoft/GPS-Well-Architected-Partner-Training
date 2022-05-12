param storageName string
param location string = resourceGroup().location
@description('Type of strage account to use')
param storageAccountType string = 'Standard_GRS'

resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageName
  location: location
  sku: {
    name: storageAccountType
  }
  kind:'StorageV2'
}
