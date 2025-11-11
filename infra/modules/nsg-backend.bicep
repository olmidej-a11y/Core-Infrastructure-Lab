param location string
param projectPrefix string

@description('Public admin IP allowed for RDP')
param adminPublicIP string




resource backendNsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: '${projectPrefix}-NSG-Backend'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-Frontend-To-Backend'
        properties: {
          description: 'Allow traffic from Frontend subnet (10.0.1.0/24)'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: '10.0.1.0/24'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-RDP-From-Admin'
        properties: {
          description: 'Allow RDP access from admin IP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '${adminPublicIP}/32'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'Deny-All'
        properties: {
          description: 'Deny all other inbound traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4000
          direction: 'Inbound'
        }
      }
    ]
  }
}

output backendNsgId string = backendNsg.id
