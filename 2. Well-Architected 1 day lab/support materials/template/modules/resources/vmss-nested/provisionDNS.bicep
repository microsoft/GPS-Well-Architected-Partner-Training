@metadata({
  Description: 'The region to deploy the resources into'
})
param location string

@metadata({
  Description: 'The name of the Virtual Network'
})
param virtualNetworkName string

@metadata({
  Description: 'The address range of the virtual network in CIDR format'
})
param virtualNetworkAddressRange string

@metadata({
  Description: 'The subnet definition for the virtual network'
})
param virtualNetworkSubnets array

@metadata({
  Description: 'The DNS address(es) of the DNS Server(s) used by the virtual network'
})
param dnsAddress array

resource vnet 'Microsoft.Network/virtualNetworks@2018-02-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressRange
      ]
    }
    dhcpOptions: {
      dnsServers: dnsAddress
    }
    subnets: virtualNetworkSubnets
  }
}
