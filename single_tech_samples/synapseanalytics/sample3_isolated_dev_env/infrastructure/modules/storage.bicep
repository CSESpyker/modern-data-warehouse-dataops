param location string = resourceGroup().location
param syn_storage_account string
param syn_storage_file_sys string
param main_storage_account string

// Data Lake Storage
resource dataLakeStorage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: main_storage_account
  location: location
  tags: {
    DisplayName: 'Data Lake Storage'
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          enabled: true
        }
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }

  resource dataLakeStorageFileSystem 'blobServices@2021-09-01' = {
    name: 'default'
    properties: {
      isVersioningEnabled: false
    }

    resource dataLakeStorageFileSystem2  'containers@2021-09-01' = {
      name: 'datalake'
      properties: {
        publicAccess: 'None'
      }
    }
  }
}

// Synapse Storage
resource synapseStorage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: syn_storage_account
  location: location
  tags: {
    DisplayName: 'Synapse Storage'
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          enabled: true
        }
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }

  resource synapseStorageFileSystem 'blobServices@2021-09-01' = {
    name: 'default'
    properties: {
      isVersioningEnabled: false
    }

    resource synapseStorageFileSystem2  'containers@2021-09-01' = {
      name: syn_storage_file_sys
      properties: {
        publicAccess: 'None'
      }
    }
  }
}

output storage_account_name string = dataLakeStorage.name
output storage_account_name_synapse string = synapseStorage.name
