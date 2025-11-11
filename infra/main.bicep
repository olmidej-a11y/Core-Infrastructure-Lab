@description('Deployment location')
param location string = resourceGroup().location

@description('Prefix for naming all resources (department or project name)')
param projectPrefix string = 'LayiCorp-IT'

@secure()
@description('Admin password for all new VMs')
param adminPassword string

@description('Admin username for all VMs')
param adminUsername string

@description('Public admin IP allowed for RDP')
param adminPublicIP string


// ─────────────────────────────
// 1.  Deploy Frontend NSG
// ─────────────────────────────
module frontendNsg './modules/nsg-frontend.bicep' = {
  name: '${projectPrefix}-frontend-nsg'
  params: {
    location: location
    projectPrefix: projectPrefix
    adminPublicIP: adminPublicIP
  }
}

// ─────────────────────────────
//  2. Deploy Backend & DB NSGs
// ─────────────────────────────
module backendNsg './modules/nsg-backend.bicep' = {
  name: '${projectPrefix}-backend-nsg'
  params: {
    location: location
    projectPrefix: projectPrefix
    adminPublicIP: adminPublicIP
  }
}

module dbNsg './modules/nsg-db.bicep' = {
  name: '${projectPrefix}-db-nsg'
  params: {
    location: location
    projectPrefix: projectPrefix
  }
}

// ─────────────────────────────
// 3. Create Public IP for Frontend
// ─────────────────────────────
module publicIp './modules/publicip.bicep' = {
  name: '${projectPrefix}-publicip'
  params: {
    location: location
    projectPrefix: projectPrefix
  }
}

// ─────────────────────────────
// 4. Extend VNet with Backend + DB subnets
// ─────────────────────────────
module network './modules/network.bicep' = {
  name: '${projectPrefix}-vnet'
  params: {
    projectPrefix: projectPrefix
    vnetName: '${projectPrefix}-VNet'
    backendNsgId: backendNsg.outputs.backendNsgId
    dbNsgId: dbNsg.outputs.dbNsgId
  }
}

// ─────────────────────────────
// 5. Create Frontend NIC (uses Frontend subnet + public IP)
// ─────────────────────────────
module nicFrontend './modules/nic.bicep' = {
  name: '${projectPrefix}-frontend-nic'
  params: {
    location: location
    projectPrefix: projectPrefix
    subnetId: network.outputs.frontendSubnetId
    publicIpId: publicIp.outputs.publicIpId
  }
}

// ─────────────────────────────
// 6. Deploy VMs (Frontend / Backend / DB)
// ─────────────────────────────
module frontendVm './modules/vm.bicep' = {
  name: '${projectPrefix}-frontend-vm'
  params: {
    location: location
    projectPrefix: projectPrefix
    nicId: nicFrontend.outputs.nicId
    adminPassword: adminPassword
    adminUsername: adminUsername
  }
}

module appVm './modules/vm-app.bicep' = {
  name: '${projectPrefix}-app-vm'
  params: {
    location: location
    projectPrefix: projectPrefix
    backendSubnetId: network.outputs.backendSubnetId
    adminPassword: adminPassword
    adminUsername: adminUsername
  }
}

module dbVm './modules/vm-db.bicep' = {
  name: '${projectPrefix}-db-vm'
  params: {
    location: location
    projectPrefix: projectPrefix
    dbSubnetId: network.outputs.dbSubnetId
    adminPassword: adminPassword
    adminUsername: adminUsername
  }
}

// ─────────────────────────────
// 7. Outputs
// ─────────────────────────────
output vnetId string = network.outputs.vnetId
output frontendVmId string = frontendVm.outputs.vmId
output appVmId string = appVm.outputs.appVmId
output dbVmId string = dbVm.outputs.dbVmId
