param location string
param vmssName string
param vmSize string

@maxValue(100)
param instanceCount int = 2
param adminUsername string

@secure()
param adminPassword string
param nicName string
param virtualNetworkName string
param subnetName string
param loadBalancerName string
param automationAccountName string
param nodeConfigurationName string = 'WindowsIISServerConfig.localhost'

var osType = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2019-Datacenter'
  version: 'latest'
}

resource automationAccount 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: automationAccountName
  location: location
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2018-10-01' = {
  name: toLower(vmssName)
  location: location
  sku: {
    name: vmSize
    tier: 'Standard'
    capacity: instanceCount
  }
  properties: {
    overprovision: false
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      storageProfile: {
        osDisk: {
          caching: 'ReadOnly'
          createOption: 'FromImage'
        }
        imageReference: osType
      }
      extensionProfile: {
        extensions: [
          {
            name: 'Microsoft.Powershell.DSC'
            properties: {
              publisher: 'Microsoft.Powershell'
              type: 'DSC'
              typeHandlerVersion: '2.76'
              autoUpgradeMinorVersion: true
              protectedSettings: {
                Items: {
                  registrationKeyPrivate: listKeys(automationAccount.id, '2018-01-15').Keys[0].value
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
          }
        ]
      }
      osProfile: {
        computerNamePrefix: toLower(take(vmssName,10))
        adminUsername: adminUsername
        adminPassword: adminPassword
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: nicName
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'ipConfig'
                  properties: {
                    subnet: {
                      id: '${resourceId('Microsoft.Network/virtualNetworks/', virtualNetworkName)}/subnets/${subnetName}'
                    }
                    loadBalancerBackendAddressPools: [
                      {
                        id: '${resourceId('Microsoft.Network/loadBalancers/', loadBalancerName)}/backendAddressPools/backendAddressPool'
                      }
                    ]
                    loadBalancerInboundNatPools: [
                      {
                        id: '${resourceId('Microsoft.Network/loadBalancers/', loadBalancerName)}/inboundNatPools/natRDPPool'
                      }
                      {
                        id: '${resourceId('Microsoft.Network/loadBalancers/', loadBalancerName)}/inboundNatPools/natWinRMPool'
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}

resource autoscalehost 'Microsoft.Insights/autoscaleSettings@2015-04-01' = {
  name: 'autoscalehost'
  location: location
  properties: {
    name: 'autoscalehost'
    targetResourceUri: resourceId('Microsoft.Compute/virtualMachineScaleSets/', vmssName)
    enabled: true
    profiles: [
      {
        name: 'Profile1'
        capacity: {
          minimum: '2'
          maximum: '25'
          default: '2'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'Percentage CPU'
              metricNamespace: ''
              metricResourceUri: resourceId('Microsoft.Compute/virtualMachineScaleSets/', vmssName)
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: 60
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT1M'
            }
          }
          {
            metricTrigger: {
              metricName: 'Percentage CPU'
              metricNamespace: ''
              metricResourceUri: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Compute/virtualMachineScaleSets/${vmssName}'
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: 30
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT1M'
            }
          }
        ]
      }
    ]
  }
  dependsOn: [
    vmss
  ]
}
