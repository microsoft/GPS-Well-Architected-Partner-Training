param artifactsLocation string
param artifactsLocationSasToken string
param automationAccountName string
param location string
param compileName string = guid(resourceGroup().id, deployment().name)

var dscConfigurations = {
  WindowsIISServerConfig: {
    name: 'WindowsIISServerConfig'
    description: 'minimum viable configuration for a web server role'
    script: 'dscConfigurations/WindowsIISServerConfig.ps1'
  }
}
var dscResources = {
  xWebAdministration: {
    name: 'xWebAdministration'
    url: 'https://psg-prod-eastus.azureedge.net/packages/xwebadministration.2.4.0.nupkg'
  }
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

resource automationAccount_dscResources_xWebAdministration 'Microsoft.Automation/automationAccounts/modules@2019-06-01' = {
  parent: automationAccount
  name: dscResources.xWebAdministration.name
  location: location
  properties: {
    contentLink: {
      uri: dscResources.xWebAdministration.url
    }
  }
}

resource automationAccount_dscConfigurations_WindowsIISServerConfig 'Microsoft.Automation/automationAccounts/configurations@2019-06-01' = {
  parent: automationAccount
  name: dscConfigurations.WindowsIISServerConfig.name
  location: location
  properties: {
    source: {
      type: 'uri'
      value: '${artifactsLocation}${dscConfigurations.WindowsIISServerConfig.script}${artifactsLocationSasToken}'
    }
  }
  dependsOn: [
    automationAccount_dscResources_xWebAdministration
  ]
}

resource automationAccount_compile 'Microsoft.Automation/automationAccounts/compilationjobs@2019-06-01' = {
  parent: automationAccount
  name: compileName
  tags: {}
  properties: {
    configuration: {
      name: dscConfigurations.WindowsIISServerConfig.name
    }
    parameters: {}
  }
  dependsOn: [
    automationAccount_dscConfigurations_WindowsIISServerConfig
  ]
}
