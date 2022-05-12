@description('Prefix to use for most of the resources.')
param environmentPrefix string = 'DevTest'

param gatewaySubnetPrefix string

param virtualNetworkName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The IP address range from which VPN clients will receive an IP address when connected. Range specified must not overlap with on-premise network.')
param vpnClientAddressPoolPrefix string

@description('The name of the client root certificate used to authenticate VPN clients. This is a common name used to identify the root cert.')
param clientRootCertName string = 'P2SRootCert'

@description('Client root certificate data used to authenticate VPN clients. Howto: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal#uploadfile')
param clientRootCertData string = 'MIIC5zCCAc+gAwIBAgIQObpaqVzeS7tHjohzgvsOEDANBgkqhkiG9w0BAQsFADAWMRQwEgYDVQQDDAtQMlNSb290Q2VydDAeFw0yMjA1MTAxMTU5MTRaFw0yMzA1MTAxMjE5MTRaMBYxFDASBgNVBAMMC1AyU1Jvb3RDZXJ0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4kmHke+DiRSAeKHhWyJmH2oFlR8tsmei+i0aNJhclZ3xj5MtN3rK08R9CAA2TFmeYEUycZugycc9uJf9O9fG+cIHkXAr/1iG/t6jNT+4k0ta2HJD+xji4Rc0pmIaPI9Zc49ZJw9nTsbhav4L5e/Bdetm+r4y57YwFxqXbR62kI3+sVXiTzYSwulkn7JLQBMtsOdiir9IoTGoJJikEyOV+ZR3Ub0K/+hrjkgM+CyTcGJR2y1I43fOiV/PgYeVGGjX7DHdqry40z6xGvE5dq82C/wCUO3khfvxDHLgeyuskTjn0GQjsj/DKyF5pIMHRMsfQQUW/QNbN2R0ZstyW+UNjQIDAQABozEwLzAOBgNVHQ8BAf8EBAMCAgQwHQYDVR0OBBYEFIUyWr24PlF5KMNN5EWhj0RjtpI3MA0GCSqGSIb3DQEBCwUAA4IBAQCYVXlYneZqjfRVv8iCfUYmt4+VcXlPJ+ZwT2basgme55K/DzMxA83Cg/kKhqp2cu/t9kzFtTUErs0eui9RxFXCg25a16+QurdjKfDD7+O7gk1SQfQQnnWhCGYXduGwc67EzDuVYHPYJMfdsUZF2dxy9hlIhAqy6rRlvSWiWgPAT6OCUU7D1ybHN1Ni1wfwO6R44nAEH001jNN+79Nxhf20aw9INYV+qRVHUQ9lEZzOOXp6w9kh3sYVwzzYKE6VQ6DuqPZPVDQIHSspd0qGl14+4mgMtL/lyuXziaIAxmAyD/gj0ltpoTof0DmnIMLbweMCv3QNBiRmGzThOgaJf9e1'

var gatewayPublicIPName = '${environmentPrefix}GatewayPIP'
var gatewayName = '${environmentPrefix}Gateway'
var gatewaySku = 'Basic'

resource gatewayPublicIP 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
  name: gatewayPublicIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-05-01' = {
  parent: vnet
  name: 'GatewaySubnet'
  properties: {
    addressPrefix: gatewaySubnetPrefix
  }
}


resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2020-07-01' = {
  name: gatewayName
  location: location
  properties: {
    ipConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
          publicIPAddress: {
            id: gatewayPublicIP.id
          }
        }
        name: 'vnetGatewayConfig'
      }
    ]
    sku: {
      name: gatewaySku
      tier: gatewaySku
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          vpnClientAddressPoolPrefix
        ]
      }
      vpnClientRootCertificates: [
        {
          name: clientRootCertName
          properties: {
            publicCertData: clientRootCertData
          }
        }
      ]
    }
  }
  dependsOn: [
    vnet
  ]
}
