param location string
param projectPrefix string
param subnetId string
param publicIpId string

resource nic 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${projectPrefix}-NIC-Frontend'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: { id: subnetId }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: { id: publicIpId }
        }
      }
    ]
  }
}

output nicId string = nic.id
