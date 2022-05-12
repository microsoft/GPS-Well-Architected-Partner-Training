param location string
param vaultName string
param vmNames array


var backupFabric = 'Azure'
var backupPolicyName = 'DefaultPolicy'
var v2VmType = 'Microsoft.Compute/virtualMachines'
var v2VmContainer = 'iaasvmcontainer;iaasvmcontainerv2;'
var v2Vm = 'vm;iaasvmcontainerv2;'

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2022-02-01' = {
  name: vaultName
  location: location
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {}
}

resource protectedItems 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2021-03-01' = [for item in vmNames: {
  name: '${vaultName}/${backupFabric}/${v2VmContainer}${resourceGroup().name};${item}/${v2Vm}${resourceGroup().name};${item}'
  location: location
  properties: {
    protectedItemType: v2VmType
    policyId: resourceId('Microsoft.RecoveryServices/vaults/backupPolicies', recoveryServicesVault.name, backupPolicyName)
    sourceResourceId: resourceId(subscription().subscriptionId, resourceGroup().name, 'Microsoft.Compute/virtualMachines', item)
  }
}]

