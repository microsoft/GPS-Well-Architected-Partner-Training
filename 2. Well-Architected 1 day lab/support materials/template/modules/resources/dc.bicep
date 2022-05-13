@description('Type of the Storage for disks')
@allowed([
  'Standard_LRS'
  'StandardSSD_LRS'
  'Premium_LRS'
])
param diskType string = 'StandardSSD_LRS'

@description('Name of the VM')
param virtualMachineName string = 'dc'

@description('Size of the VM')
param vmSize string = 'Standard_D2s_v3'

@description('Image SKU')
@allowed([
  '2012-R2-Datacenter'
  '2016-Datacenter'
  '2019-Datacenter'
])
param imageSKU string = '2019-Datacenter'

@description('Admin username')
param adminUsername string

@description('Admin password')
@secure()
param adminPassword string

//TODO: create Windows DCServer config
param nodeConfigurationName string = 'WindowsIISServerConfig.localhost'

@description('Location for all resources.')
param location string = resourceGroup().location

param existingVirtualNetworkName string
param existingSubnetName string
param networkSecurityGroupName string

//todo extract automation script
var automationAccountName = 'DSC-${take(guid(resourceGroup().id), 5)}'

var vmName = take(toLower(virtualMachineName),15)
var nicName = 'dscNIC'
var imagePublisher = 'MicrosoftWindowsServer'
var imageOffer = 'WindowsServer'

resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: existingVirtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-05-01' existing = {
  parent: vnet
  name: existingSubnetName
}

resource automationAccount 'Microsoft.Automation/automationAccounts@2021-06-22' existing = {
  name: automationAccountName
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-05-01' existing = {
  name: networkSecurityGroupName
}

resource nsgRules3389 'Microsoft.Network/networkSecurityGroups/securityRules@2021-08-01' = {
  parent: nsg
  name: '${vmName}-allow-3389'
  properties: {
    priority: 1002
    access: 'Allow'
    direction: 'Inbound'
    destinationPortRange: '3389'
    protocol: 'Tcp'
    sourceAddressPrefix: '*'
    sourcePortRange: '*'
    destinationAddressPrefix: nic.properties.ipConfigurations[0].properties.privateIPAddress
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
  }
  dependsOn: [
    subnet
  ]
}

resource vm 'Microsoft.Compute/virtualMachines@2019-12-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSKU
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: diskType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
  dependsOn: [
    automationAccount
  ]
}

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2019-12-01' = {
  parent: vm
  location: location

  name: 'Microsoft.Powershell.DSC'
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.76'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      Items: {
        registrationKeyPrivate: listKeys(automationAccount.id, '2021-06-22').Keys[0].value
      }
    }
    settings: {
      Properties: [
        {
          Name: 'RegistrationKey'
          Value: {
            UserName: 'PLACEHOLDER_DONOTUSE'
            Password: 'PrivateSettingsRef:registrationKeyPrivate'
          }
          TypeName: 'System.Management.Automation.PSCredential'
        }
        {
          Name: 'RegistrationUrl'
          Value: automationAccount.properties.registrationUrl
          TypeName: 'System.String'
        }
        {
          Name: 'NodeConfigurationName'
          Value: nodeConfigurationName
          TypeName: 'System.String'
        }
        {
          Name: 'ConfigurationMode'
          Value: 'ApplyandAutoCorrect'
          TypeName: 'System.String'
        }
        {
          Name: 'RebootNodeIfNeeded'
          Value: true
          TypeName: 'System.Boolean'
        }
        {
          Name: 'ActionAfterReboot'
          Value: 'ContinueConfiguration'
          TypeName: 'System.String'
        }
      ]
    }
  }
  dependsOn: [
    automationAccount
  ]
}
