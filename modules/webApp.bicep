param name string
param location string = resourceGroup().location
param appServicePlanId string

param registryName string
@secure()
param registryServerUserName string
@secure()
param registryServerPassword string
param registryImageName string
param registryImageVersion string
param appSettings array = []
var dockerAppSettings = [
  { name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE', value: 'false' }
  { name: 'DOCKER_REGISTRY_SERVER_URL', value: 'https://${registryName}.azurecr.io' }
  { name: 'DOCKER_REGISTRY_SERVER_USERNAME', value: registryServerUserName }
  { name: 'DOCKER_REGISTRY_SERVER_PASSWORD', value: registryServerPassword }
]

resource containerAppService 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${registryName}.azurecr.io/${registryImageName}:${registryImageVersion}'
      appCommandLine: ''
      appSettings: union(appSettings, dockerAppSettings)
    }
  }
}
