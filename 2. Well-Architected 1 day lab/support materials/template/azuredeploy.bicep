targetScope = 'subscription'

@description('Location for all resources.')
param location string = deployment().location

param name string

@secure()
param adminPassword string

@description('Default true. Set it to false to not deploy development resources.')
param devDeploy bool = true

@description('Default true. Set it to false to not deploy production resources.')
param prodDeploy bool = true

@description('Default true. Set it to false to avoid the deployment of the VPN Gateway in production. It takes more than 15 minutes to deploy, so setting it to false it is useful when testing the template.')
param vpnEnabled bool = true

@description('Default true. Set it to false to avoid the deployment of the Backup in production. It takes long time to delete, so setting it to false it is useful when testing the template.')
param backupEnabled bool = true

var prodRGName = '${name}prod'
var devRGName = '${name}dev'


resource prodrg 'Microsoft.Resources/resourceGroups@2021-01-01' = if(prodDeploy) {
  name: prodRGName
  location: location
  tags:{
    'environment': 'dev'
  }
}

resource devrg 'Microsoft.Resources/resourceGroups@2021-01-01' = if(devDeploy) {
  name: devRGName
  location: location
  tags: {
    'environment': 'prod'
  }
}

module prod 'modules/production.bicep' = if(prodDeploy) {
  name: 'production'
  scope: prodrg
  params: {
    location: location
    name: name
    adminPassword: adminPassword
    vpnEnabled: vpnEnabled
    backupEnabled: backupEnabled
  }
}

module dev 'modules/development.bicep' = if(devDeploy) {
  name: 'development'
  scope: devrg
  params: {
    location: location
    name: name
    adminPassword: adminPassword
  }
}

