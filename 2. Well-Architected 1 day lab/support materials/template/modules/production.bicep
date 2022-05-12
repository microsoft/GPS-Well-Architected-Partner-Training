param name string

@description('Location for all resources.')
param location string = resourceGroup().location
param adminUsername string = 'sqladmin'
@secure()
param adminPassword string

param addressPrefix string = '10.0.0.0/16'
param subnetPrefix string = '10.0.0.0/24'
param lbSubnetPrefix string = '10.0.1.0/24'
param bastionSubnetIpPrefix string = '10.0.2.0/24'
param vpnEnabled bool = true
param backupEnabled bool = true
param vpnSubnetPrefix string= '10.0.3.0/24'
param vpnClientAddressPoolPrefix string = '10.10.8.0/24'
param dcSubnetPrefix string = '10.0.10.0/24'


var uniqueName = substring('${name}prod${uniqueString(resourceGroup().id)}',0,10)
var sqlVmName='${uniqueName}sql'
var vnetName= '${uniqueName}vnet'
var dcName='${uniqueName}dc'

module vNet 'resources/vnet.bicep' = {
  name: vnetName
  params: {
    location: location
    virtualNetworkName: vnetName
    addressPrefix: addressPrefix
    subnetPrefix: subnetPrefix
    lbSubnetPrefix: lbSubnetPrefix
    withLb: true
    dcSubnetPrefix: dcSubnetPrefix
    withDc: true

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
    storageDiskSize: 2048
    storageAccountType: 'StandardSSD_LRS'
  }
  dependsOn: [
    vNet
  ]
}

module frontend 'resources/vmss.bicep' = {
  name: '${uniqueName}_frontend'
  params: {
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    nicIPAddress: '10.0.1.4' //TODO: find address
    virtualNetworkName: vNet.outputs.virtualNetworkName
    virtualNetworkSubnetName: vNet.outputs.lbSubnetName
  }
  dependsOn: [
    vNet
  ]
}

module bastion 'resources/bastion.bicep' = {
  name: '${uniqueName}_bastion'
  params: {
    location: location
    bastionHostName: '${uniqueName}bastion'
    bastionSubnetIpPrefix: bastionSubnetIpPrefix
    virtualNetworkName: vNet.outputs.virtualNetworkName
  }
  dependsOn: [
    vNet
    sqlVm
  ]
}

module dc 'resources/dc.bicep' = {
  name: dcName
  params: {
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmName: dcName
    existingVirtualNetworkName: vNet.outputs.virtualNetworkName
    existingSubnetName: vNet.outputs.dcSubnetName
    networkSecurityGroupName: vNet.outputs.networkSecurityGroupName
  }
  dependsOn: [
    vNet
  ]
}

module vpn 'resources/vpn.bicep' = if(vpnEnabled) {
  name: '${uniqueName}_vpn'
  params: {
    location: location
    environmentPrefix: 'Prod'
    virtualNetworkName: vNet.outputs.virtualNetworkName
    gatewaySubnetPrefix: vpnSubnetPrefix
    vpnClientAddressPoolPrefix: vpnClientAddressPoolPrefix
  }
  dependsOn: [
    vNet
  ]
}

module backup 'resources/backup.bicep' = if(backupEnabled) {
  name: '${uniqueName}_backup'
  params: {
    location: location
    vaultName: '${uniqueName}backup'
    vmNames: [
      sqlVm.outputs.virtualMachineName
    ]
  }
}
