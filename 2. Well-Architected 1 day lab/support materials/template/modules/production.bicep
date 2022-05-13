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


var uniqueName = take('${take(name,5)}pro${uniqueString(resourceGroup().id)}',11)
var sqlVmName='${uniqueName}sql'
var vnetName= '${uniqueName}vnet'
var dcName='${uniqueName}dc'
var storageName='${uniqueName}storage'
var frontendName='${uniqueName}web'
var bastionName='${uniqueName}bastion'
var vpnName='${uniqueName}vpn'
var backupName='${uniqueName}backup'
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
  name: frontendName
  params: {
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    // nicIPAddress: '10.0.1.4' //TODO: find address
    virtualNetworkName: vNet.outputs.virtualNetworkName
    virtualNetworkSubnetName: vNet.outputs.lbSubnetName
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
    storageAccountType: 'Standard_LRS'
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

module dc 'resources/dc.bicep' = {
  name: dcName
  params: {
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    virtualMachineName: dcName
    existingVirtualNetworkName: vNet.outputs.virtualNetworkName
    existingSubnetName: vNet.outputs.dcSubnetName
    networkSecurityGroupName: vNet.outputs.networkSecurityGroupName
  }
  dependsOn: [
    vNet
    frontend
  ]
}

module vpn 'resources/vpn.bicep' = if(vpnEnabled) {
  name: vpnName
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
  name: backupName
  params: {
    location: location
    vaultName: backupName
    vmNames: [
      sqlVm.outputs.virtualMachineName
    ]
  }
}
