param location string
param key_vault_name string


resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: key_vault_name
  location: location
  properties: {
    createMode: 'default'
    enablePurgeProtection: true
    enableRbacAuthorization: true
    enableSoftDelete: true
    publicNetworkAccess: 'enabled'
    sku: {
      family: 'A'
      name: 'standard'
    }
    softDeleteRetentionInDays: 7
    tenantId: subscription().tenantId
  }
}
