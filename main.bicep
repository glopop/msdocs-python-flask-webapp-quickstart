param userAlias string = 'glopop'
param location string = resourceGroup().location


// App Service Plan
param appServicePlanName string 

module appServicePlan 'modules/appServicePlan.bicep' = {
  name: 'appServicePlan-${userAlias}'
  params: {
    name: appServicePlanName
    location: location
  }
}

// Key Vault
param keyVaultName string
param keyVaultRoleAssignments array

module keyvault 'modules/keyvault.bicep' = {
  name: 'keyVault-${userAlias}'
  params: {
    name: keyVaultName
    location: location
    roleAssignments: keyVaultRoleAssignments
  }
}

// Container Registry
param containerRegistryName string
param containerRegistryUsernameSecretName string 
param containerRegistryPassword0SecretName string 
param containerRegistryPassword1SecretName string 

module acr 'modules/acr.bicep' = {
  name: 'containerRegistry-${userAlias}'
  params: {
    name: containerRegistryName
    location: location
    keyVaultResourceId: keyvault.outputs.keyVaultId
    usernameSecretName: containerRegistryUsernameSecretName
    password0SecretName: containerRegistryPassword0SecretName
    password1SecretName: containerRegistryPassword1SecretName
  }
}

// Container App Service
param containerName string
param dockerRegistryImageName string
param dockerRegistryImageVersion string

resource keyVaultReference 'Microsoft.KeyVault/vaults@2023-07-01'existing = {
  name: keyVaultName
}

module webApp 'modules/webApp.bicep' = {
  name: 'containerAppService-${userAlias}'
  params: {
    name: containerName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    registryName: containerRegistryName
    registryImageName: dockerRegistryImageName
    registryImageVersion: dockerRegistryImageVersion
    registryServerUserName: keyVaultReference.getSecret(containerRegistryUsernameSecretName)
    registryServerPassword: keyVaultReference.getSecret(containerRegistryPassword0SecretName)
  }
}

