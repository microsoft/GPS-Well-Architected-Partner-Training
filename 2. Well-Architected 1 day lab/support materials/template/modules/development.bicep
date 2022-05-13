param name string

@description('Location for all resources.')
param location string = resourceGroup().location
param adminUsername string = 'sqladmin'

@secure()
param adminPassword string

param addressPrefix string = '10.1.0.0/16'
param subnetPrefix string = '10.1.0.0/24'
param bastionSubnetIpPrefix string = '10.1.2.0/24'

var uniqueName = take('${take(name,5)}dev${uniqueString(resourceGroup().id)}',11)
var sqlVmName='${uniqueName}sql'
var vnetName= '${uniqueName}vnet'
var storageName='${uniqueName}storage'
var frontendName='${uniqueName}web'
var bastionName='${uniqueName}bastion'
module vNet 'resources/vnet.bicep' = {
  name: vnetName
  params: {
    location: location
    virtualNetworkName: vnetName
    addressPrefix: addressPrefix
    subnetPrefix: subnetPrefix
  }
}

module sqlVm 'resources/sqlvm.bicep' = {
  name: sqlVmName
  params:{
    location: location
    virtualMachineName: sqlVmName
    existingVirtualNetworkName: vNet.outputs.virtualNetworkName
    existingSubnetName: vNet.outputs.defaultSubnetName
    adminUsername: adminUsername
    adminPassword: adminPassword
    storageDiskSize: 1023
  }
  dependsOn: [
    vNet
  ]
}

module frontend 'resources/webvm.bicep' = {
  name: frontendName
  params: {
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    virtualMachineName: frontendName
    existingVirtualNetworkName: vNet.outputs.virtualNetworkName
    existingSubnetName: vNet.outputs.defaultSubnetName
    networkSecurityGroupName: vNet.outputs.networkSecurityGroupName
  }
  dependsOn: [
    vNet
  ]
}

module storage 'resources/storage.bicep' = {
  name: storageName
  params:{
    location: location
    storageName:storageName
  }
}


module bastion 'resources/bastion.bicep' = {
  name: bastionName
  params: {
    location: location
    bastionHostName: bastionName
    bastionSubnetIpPrefix: bastionSubnetIpPrefix
    virtualNetworkName: vNet.outputs.virtualNetworkName
  }
  dependsOn: [
    vNet
    sqlVm
  ]
}
