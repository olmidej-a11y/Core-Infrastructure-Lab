param location string
param projectPrefix string
param backendSubnetId string

@secure()
param adminPassword string

param adminUsername string

resource appNic 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${projectPrefix}-NIC-App'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: { id: backendSubnetId }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource appVm 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: '${projectPrefix}-VM-App'
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
      computerName: '${projectPrefix}-APP'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        { id: appNic.id }
      ]
    }
  }
}

output appVmId string = appVm.id
output appNicId string = appNic.id
