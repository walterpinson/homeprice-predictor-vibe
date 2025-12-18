targetScope = 'resourceGroup'

// =============================================================================
// PARAMETERS
// =============================================================================

@description('Base name for all resources (used as prefix)')
param baseName string

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('VM size for the AML compute cluster')
param computeVmSize string = 'Standard_DS3_v2'

@description('Minimum number of nodes in the compute cluster')
param computeMinNodes int = 0

@description('Maximum number of nodes in the compute cluster')
param computeMaxNodes int = 4

@description('Idle time in seconds before scaling down')
param computeIdleTimeBeforeScaleDown int = 120

// =============================================================================
// VARIABLES
// =============================================================================

var storageAccountName = '${toLower(replace(baseName, '-', ''))}st'
var keyVaultName = '${baseName}-kv'
var appInsightsName = '${baseName}-ai'
var containerRegistryName = '${toLower(replace(baseName, '-', ''))}acr'
var workspaceName = '${baseName}-mlw'
var computeClusterName = 'cpu-cluster'

// =============================================================================
// STORAGE ACCOUNT
// =============================================================================

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}

// =============================================================================
// KEY VAULT
// =============================================================================

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enableRbacAuthorization: true
  }
}

// =============================================================================
// APPLICATION INSIGHTS
// =============================================================================

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// =============================================================================
// CONTAINER REGISTRY
// =============================================================================

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
    publicNetworkAccess: 'Enabled'
  }
}

// =============================================================================
// AZURE MACHINE LEARNING WORKSPACE
// =============================================================================

resource mlWorkspace 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: workspaceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: workspaceName
    storageAccount: storageAccount.id
    keyVault: keyVault.id
    applicationInsights: appInsights.id
    containerRegistry: containerRegistry.id
    publicNetworkAccess: 'Enabled'
  }
}

// =============================================================================
// AML COMPUTE CLUSTER
// =============================================================================

resource computeCluster 'Microsoft.MachineLearningServices/workspaces/computes@2024-04-01' = {
  name: computeClusterName
  parent: mlWorkspace
  location: location
  properties: {
    computeType: 'AmlCompute'
    properties: {
      vmSize: computeVmSize
      scaleSettings: {
        minNodeCount: computeMinNodes
        maxNodeCount: computeMaxNodes
        nodeIdleTimeBeforeScaleDown: 'PT${computeIdleTimeBeforeScaleDown}S'
      }
      osType: 'Linux'
      remoteLoginPortPublicAccess: 'Disabled'
    }
  }
}

// =============================================================================
// OUTPUTS
// =============================================================================

output workspaceName string = mlWorkspace.name
output workspaceId string = mlWorkspace.id
output storageAccountName string = storageAccount.name
output keyVaultName string = keyVault.name
output containerRegistryName string = containerRegistry.name
output appInsightsName string = appInsights.name
output computeClusterName string = computeCluster.name
