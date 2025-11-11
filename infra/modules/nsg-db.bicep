param location string
param projectPrefix string

resource dbNsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: '${projectPrefix}-NSG-DB'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-Backend-To-DB'
        properties: {
          description: 'Allow SQL traffic from backend subnet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: '10.0.2.0/24'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
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

output dbNsgId string = dbNsg.id
