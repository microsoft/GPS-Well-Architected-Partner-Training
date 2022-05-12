# WAF Resources template

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmicrosoft%2FGPS-Well-Architected-Partner-Training-generator%2Fmain%2Fcoach-materials%2F2.%2520Well-Architected%25201%2520day%2520lab%2Fsupport%2520materials%2Ftemplate%2Fazuredeploy.json%3Ftoken%3DGHSAT0AAAAAABSTSGTGAVMFTLQVNTHKWWZOYT43AKQ)

This is an ARM template for creating the WAF architecture for this exercise. Take into account that the bill of these resources can be huge, it is intended to be used as a starting point for the rest of the exercise, and deleted after the exercise is completed.

It is parameterized with the following parameters:

* name: the base name for the resources.
* adminPassword: the password for the admin user in the VMs and the SQL Database.
* devDeploy: a boolean value to set to false when you don't want to deploy the development resources. Default value `true`.
* prodDeploy: a boolean value to set to false when you don't want to deploy the production resources. Default value `true`.
* vpnEnabled: set it to false to avoid the deployment of the VPN Gateway in production. It takes more than 15 minutes to deploy, so setting it to false it is useful when testing the template. Default `true`.

The command to deploy the resources is:

````bash
az deployment sub create --location [location] -n [name] -f .\azuredeploy.bicep -p '@params.json'
```
