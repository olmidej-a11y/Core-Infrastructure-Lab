param location string
param projectPrefix string

@description('Public admin IP allowed for RDP')
param adminPublicIP string
 

resource frontendNsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: '${projectPrefix}-NSG-Frontend'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP'
        properties: {
          description: 'Allow HTTP web traffic'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-RDP'
        properties: {
          description: 'Allow RDP from admin IP'
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
        name: 'Deny-All-Others'
        properties: {
          description: 'Deny everything else inbound'
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

output frontendNsgId string = frontendNsg.id
