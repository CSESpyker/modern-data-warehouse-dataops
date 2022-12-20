param location string = resourceGroup().location
param syn_storage_account string
param main_storage_account string
param syn_storage_file_sys string
param syn_worskpace_name string
param synapse_spark_sql_pool_name string
param key_vault_name string

//https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var storage_blob_data_contributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
var key_vault_reader = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '21090545-7ca7-4776-b22c-e363652d74d2')


resource synStorage 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: syn_storage_account
}

resource synFileSystem 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' existing = {
  name: syn_storage_file_sys
}

resource mainStorage 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: main_storage_account
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: key_vault_name
}

resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: syn_worskpace_name
  tags: {
    DisplayName: 'Synapse Workspace'
  }
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      accountUrl: 'https://${synStorage.name}.dfs.${environment().suffixes.storage}'
      filesystem: synFileSystem.name
    }
    publicNetworkAccess: 'Enabled'
    managedResourceGroupName: '${syn_worskpace_name}-mrg'
    workspaceRepositoryConfiguration: {
      accountName: 'CSESpyker'
      collaborationBranch: 'main'
      repositoryName: 'modern-data-warehouse-dataops'
      rootFolder: '/single_tech_samples/synapseanalytics/sample3_isolated_dev_env/artifacts'
      type: 'WorkspaceGitHubConfiguration'
    }
  }
}

resource synapseWorkspaceFirewallRule1 'Microsoft.Synapse/workspaces/firewallrules@2021-06-01' = {
  parent: synapseWorkspace
  name: 'allowAll'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource synapse_spark_sql_pool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  parent: synapseWorkspace
  name: synapse_spark_sql_pool_name
  location: location
  tags: {
    DisplayName: 'Spark SQL Pool'
  }
  properties: {
    isComputeIsolationEnabled: false
    nodeSizeFamily: 'MemoryOptimized'
    nodeSize: 'Small'
    autoScale: {
      enabled: true
      minNodeCount: 3
      maxNodeCount: 10
    }
    dynamicExecutorAllocation: {
      enabled: false
    }
    autoPause: {
      enabled: true
      delayInMinutes: 15
    }
    sparkVersion: '3.2'
    sessionLevelPackagesEnabled: true
    customLibraries: []
    defaultSparkLogFolder: 'logs/'
    sparkEventsFolder: 'events/'
  }
}

resource roleAssignmentSynStorage1 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, resourceId('Microsoft.Storage/storageAccounts', synStorage.name))
  properties: {
    principalId: synapseWorkspace.identity.principalId
    roleDefinitionId: storage_blob_data_contributor
    principalType: 'ServicePrincipal'
  }
  scope: synStorage
}

resource roleAssignmentSynStorage2 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, resourceId('Microsoft.Storage/storageAccounts', mainStorage.name))
  properties: {
    principalId: synapseWorkspace.identity.principalId
    roleDefinitionId: storage_blob_data_contributor
    principalType: 'ServicePrincipal'
  }
  scope: mainStorage
}

resource roleAssignmentKeyvault 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, resourceId('Microsoft.KeyVault/vaults', keyVault.name))
  properties: {
    principalId: synapseWorkspace.identity.principalId
    roleDefinitionId: key_vault_reader
    principalType: 'ServicePrincipal'
  }
  scope: keyVault
}

output synapseWorkspaceName string = synapseWorkspace.name
output synapseDefaultStorageAccountName string = synStorage.name
output synapseSparkPoolName string = synapse_spark_sql_pool.name
