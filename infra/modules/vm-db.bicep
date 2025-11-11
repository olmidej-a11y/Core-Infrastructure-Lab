param location string
param projectPrefix string
param dbSubnetId string

@secure()
param adminPassword string

param adminUsername string

resource dbNic 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${projectPrefix}-NIC-DB'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: { id: dbSubnetId }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource dbVm 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: '${projectPrefix}-VM-DB'
  location: location
  identity: { type: 'SystemAssigned' }
  properties: {
    hardwareProfile: { vmSize: 'Standard_B1s' }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-g2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        deleteOption: 'Delete'
      }
    }
    osProfile: {
      computerName: '${projectPrefix}-DB'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        { id: dbNic.id }
      ]
    }
  }
}

output dbVmId string = dbVm.id
output dbNicId string = dbNic.id
