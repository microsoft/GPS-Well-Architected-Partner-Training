param name string

@description('Location for all resources.')
param location string = resourceGroup().location
param adminUsername string = 'sqladmin'

@secure()
param adminPassword string

param addressPrefix string = '10.1.0.0/16'
param subnetPrefix string = '10.1.0.0/24'
param bastionSubnetIpPrefix string = '10.1.2.0/24'

var uniqueName = substring('${name}dev${uniqueString(resourceGroup().id)}',0,10)
var sqlVmName='${uniqueName}sql'
var vnetName= '${uniqueName}vnet'
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
    vmName: frontendName
    existingVirtualNetworkName: vNet.outputs.virtualNetworkName
    existingSubnetName: vNet.outputs.defaultSubnetName
    networkSecurityGroupName: vNet.outputs.networkSecurityGroupName
  }
  dependsOn: [
    vNet
  ]
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
