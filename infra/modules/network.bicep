@description('Prefix for naming all resources')
param projectPrefix string

@description('Name of the virtual network')
param vnetName string = '${projectPrefix}-VNet'

@description('Address space for the VNet')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Address prefix for Frontend subnet')
param frontendSubnetPrefix string = '10.0.1.0/24'

@description('Address prefix for Backend subnet')
param backendSubnetPrefix string = '10.0.2.0/24'

@description('Address prefix for DB subnet')
param dbSubnetPrefix string = '10.0.3.0/24'

@description('Backend NSG ID to attach')
param backendNsgId string

@description('DB NSG ID to attach')
param dbNsgId string

// ─────────────────────────────
// Create the base VNet + Frontend subnet
// ─────────────────────────────
resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'Frontend'
        properties: {
          addressPrefixes: [
            frontendSubnetPrefix
          ]
        }
      }
    ]
  }
}

// ────────────────────────
// Create Backend subnet
// ────────────────────────
resource backendSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: 'Backend'
  parent: vnet
  properties: {
    addressPrefixes: [
      backendSubnetPrefix
    ]
    networkSecurityGroup: {
      id: backendNsgId
    }
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

// ───────────────────
// Create DB subnet
// ───────────────────
resource dbSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: 'DB'
  parent: vnet
  properties: {
    addressPrefixes: [
      dbSubnetPrefix
    ]
    networkSecurityGroup: {
      id: dbNsgId
    }
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

// ─────────
// Outputs
// ─────────
output vnetId string = vnet.id
output frontendSubnetId string = '${vnet.id}/subnets/Frontend'
output backendSubnetId string = backendSubnet.id
output dbSubnetId string = dbSubnet.id
