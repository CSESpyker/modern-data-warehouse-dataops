param project string
param location string = resourceGroup().location
param environment_id string

param synStorageAccount string = '${project}${environment_id}dlstacc'
param mainStorageAccount string = '${project}${environment_id}synstacc'
param synStorageFileSys string = 'synapsedefaults'
param synWorkspaceName string = '${project}${environment_id}synws'
param SynapseSparkPoolName string = '${project}${environment_id}synsp'

module storage './modules/storage.bicep' = {
  name: 'storage_deploy_${environment_id}'
  params: {
    location: location
    syn_storage_account: synStorageAccount
    main_storage_account: mainStorageAccount
    syn_storage_file_sys: synStorageFileSys
  }
}

module synapse './modules/synapse.bicep' = {
  name: 'synapse_deploy_${environment_id}'
  params: {
    location: location
    syn_storage_account: synStorageAccount
    main_storage_account: mainStorageAccount
    syn_storage_file_sys: synStorageFileSys
    syn_worskpace_name: synWorkspaceName
    synapse_spark_sql_pool_name: SynapseSparkPoolName
  }
}

output storage_account_name string = synStorageAccount
output synapseworkspace_name string = synWorkspaceName
output synapse_output_spark_pool_name string = SynapseSparkPoolName
