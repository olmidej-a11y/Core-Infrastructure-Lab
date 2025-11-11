@description('Azure region for deployment')
param location string

@description('Prefix for naming all resources')
param projectPrefix string

@description('Public IP SKU ')
@allowed([
  'Standard'
  'Basic'
])
param publicIpSku string = 'Standard'

@description('Allocation method for the public IP address')
@allowed([
  'Static'
  'Dynamic'
])
param allocationMethod string = 'Static'

// ─────────────────────────────
// Create Public IP Address
// ─────────────────────────────
resource publicIp 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: '${projectPrefix}-PublicIP'
  location: location
  sku: {
    name: publicIpSku
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: allocationMethod
    dnsSettings: {
      domainNameLabel: toLower('${projectPrefix}-web')
    }
  }
}

// ─────────────────────────────
// Output
// ─────────────────────────────
output publicIpId string = publicIp.id
output publicIpAddress string = publicIp.properties.ipAddress
output dnsName string = publicIp.properties.dnsSettings.domainNameLabel
