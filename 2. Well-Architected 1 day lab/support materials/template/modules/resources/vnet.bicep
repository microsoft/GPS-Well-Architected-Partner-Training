param virtualNetworkName string

param addressPrefix string = '10.0.0.0/16'
param subnetPrefix string = '10.0.0.0/24'
param withLb bool = false
param lbSubnetPrefix string = '10.0.1.0/24'
param withDc bool = false
param dcSubnetPrefix string = '10.0.10.0/24'

@description('Location for all resources.')
param location string = resourceGroup().location

var networkSecurityGroupName = 'DefaultNSG${virtualNetworkName}'
var defaultSubnetName = 'Default'

var lbSubnetName = 'LBSubnet'
var dcSubnetName = 'DCSubnet'

resource securityGroup 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: networkSecurityGroupName
  location: location
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: defaultSubnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: securityGroup.id
          }
        }
      }
    ]
  }

  resource defaultSubnet 'subnets' existing = {
    name: defaultSubnetName
  }
}

resource lbSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = if(withLb) {
  name: lbSubnetName
  parent: vnet
  properties: {
    addressPrefix: lbSubnetPrefix
  }
}

resource dcSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = if(withDc) {
  name: dcSubnetName
  parent: vnet
  properties: {
    addressPrefix: dcSubnetPrefix
  }
  dependsOn:[
    lbSubnet
  ]
}

output virtualNetworkName string = vnet.name
output defaultSubnetName string = vnet::defaultSubnet.name
output virtualNetworkId string = vnet.id
output defaultSubnetId string = vnet::defaultSubnet.id
output lbSubnetId string = lbSubnet.id
output lbSubnetName string = lbSubnet.name
output dcSubnetId string = dcSubnet.id
output dcSubnetName string = dcSubnet.name
output networkSecurityGroupName string = securityGroup.name
