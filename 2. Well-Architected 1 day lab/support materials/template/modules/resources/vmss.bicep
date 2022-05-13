@description('The Azure location to deploy all resources')
param location string

@description('Naming convention for the vm scale set')
param vmssName string = 'srv'

@description('The number of vms to  provision initially in the scale set')
param instanceCount int = 2

// @description('The IP address of the new AD VM')
// param nicIPAddress string

@description('The name of the Administrator of the new VM and Domain')
param adminUsername string

@description('The password for the Administrator account of the new VM and Domain')
@secure()
param adminPassword string

@description('The size of the VM Created')
param VMSize string = 'Standard_B2s'

// @description('The full qualified domain name to be created')
// param domainName string = 'contoso.local'

@description('Path to the nested templates used in this deployment')
param artifactsLocation string = 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.compute/vmss-automation-dsc/'

@description('SAS token to access artifacts location, if required')
param artifactsLocationSasToken string = ''

@description('Unique value to identify compilation job')
param compileName string = guid(resourceGroup().id, deployment().name)


//todo: extract automation parameters to a separate file
var automationAccountName = 'DSC-${take(guid(resourceGroup().id), 5)}'
var publicIPAddressName = 'PIP'
var publicIPAddressType = 'Dynamic'
param virtualNetworkName string
param virtualNetworkSubnetName string
var loadBalancerName = 'LoadBalancer'
var nicName = 'NIC'

module provisionConfiguration 'vmss-nested/provisionConfiguration.bicep' = {
  name: 'provisionConfiguration'
  params: {
    artifactsLocation: artifactsLocation
    artifactsLocationSasToken: artifactsLocationSasToken
    automationAccountName: automationAccountName
    location: location
    compileName: compileName
  }
}

module provisionLB 'vmss-nested/provisionLB.bicep' = {
  name: 'provisionLB'
  params: {
    location: location
    publicIPAddressName: publicIPAddressName
    publicIPAddressType: publicIPAddressType
    loadBalancerName: loadBalancerName
  }
}

module provisionServer 'vmss-nested/provisionServer.bicep' = {
  name: 'provisionWebServer'
  params: {
    location: location
    vmssName: vmssName
    instanceCount: instanceCount
    vmSize: VMSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    nicName: nicName
    virtualNetworkName: virtualNetworkName
    subnetName: virtualNetworkSubnetName
    loadBalancerName: loadBalancerName
    automationAccountName: automationAccountName
  }
  dependsOn: [
    provisionLB
    provisionConfiguration
  ]
}

// module provisionDNS 'vmss-nested/provisionDNS.bicep' = {
//   name: 'provisionDNS'
//   params: {
//     location: location
//     virtualNetworkName: virtualNetworkName
//     virtualNetworkAddressRange: virtualNetworkAddressRange
//     virtualNetworkSubnets: virtualNetworkSubnets
//     dnsAddress: [
//       nicIPAddress
//     ]
//   }
//   dependsOn: [
//     provisionServer
//   ]
// }
