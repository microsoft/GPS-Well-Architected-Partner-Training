param location string
param publicIPAddressName string
param publicIPAddressType string
param loadBalancerName string
param httpProbeRequestPath string = '/iisstart.htm'


resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2018-12-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAddressType
  }
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2018-12-01' = {
  name: loadBalancerName
  location: location
  properties: {
    frontendIPConfigurations: [
      {
        name: 'frontendIPConfiguration'
        properties: {
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backendAddressPool'
      }
    ]
    probes: [
      {
        name: 'httpProbe'
        properties: {
          protocol: 'Http'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
          requestPath: httpProbeRequestPath
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'loadBalancingRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, 'frontendIPConfiguration')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, 'backendAddressPool')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 5
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, 'httpProbe')
          }
        }
      }
    ]
    inboundNatPools: [
      {
        name: 'natRDPPool'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, 'frontendIPConfiguration')
          }
          protocol: 'Tcp'
          frontendPortRangeStart: 50000
          frontendPortRangeEnd: 50119
          backendPort: 3389
        }
      }
      {
        name: 'natWinRMPool'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, 'frontendIPConfiguration')
          }
          protocol: 'Tcp'
          frontendPortRangeStart: 51000
          frontendPortRangeEnd: 51119
          backendPort: 5896
        }
      }
    ]
  }
}
