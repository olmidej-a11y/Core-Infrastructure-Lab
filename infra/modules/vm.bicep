param location string
param projectPrefix string
param nicId string

@secure()
param adminPassword string

@description('Local admin username (do not hardcode).')
param adminUsername string

resource vm 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: '${projectPrefix}-VM-Frontend'
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
      computerName: '${projectPrefix}-WEB'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        { id: nicId }
      ]
    }
  }
}

output vmId string = vm.id
