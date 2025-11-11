# LayiCorp Core Infrastructure – Azure Bicep Project

## Overview

This project automates the end-to-end deployment of a three-tier Azure infrastructure (Frontend, Application, and Database layers) using Azure Bicep.  
The design follows enterprise-level standards for modularity, network segmentation, and security. Each department (IT, HR, SM) can be deployed independently using the same reusable Bicep modules and parameterization.

---

## Architecture

The deployment provisions a complete infrastructure stack for each department:

| Layer | Resource | Description |
|:------|:----------|:-------------|
| Network | Virtual Network with 3 subnets | Frontend, Backend, and DB subnets for isolation |
| Security | 3 Network Security Groups | Layered access control for each subnet |
| Compute | 3 Windows Server 2022 VMs | Frontend (Web), Application, and Database servers |
| Public Access | Standard static Public IP and DNS label | External access to the Frontend VM |
| Automation | Modular Bicep templates | Each component defined as a standalone module |

---

## Bicep Module Structure

```
infra/
│
├── main.bicep                     # Root orchestration file
├── main.parameters.IT.json        # Parameters for IT department
├── main.parameters.HR.json        # Parameters for HR department
├── main.parameters.SM.json        # Parameters for SM department
│
└── modules/
    ├── network.bicep
    ├── nsg-frontend.bicep
    ├── nsg-backend.bicep
    ├── nsg-db.bicep
    ├── publicip.bicep
    ├── nic.bicep
    ├── vm.bicep
    ├── vm-app.bicep
    └── vm-db.bicep
```

Each module defines one resource type. This structure ensures reusability and clear separation of concerns.

---

## Network Security Rules

| NSG | Rule | Port | Source | Destination | Action |
|:----|:------|:------|:----------|:-------------|:----------|
| Frontend | Allow HTTP | 80 | Any | Any | Allow |
| Frontend | Allow RDP | 3389 | Admin Public IP | Any | Allow |
| Frontend | Deny-All-Others | Any | Any | Any | Deny |
| Backend | Allow Frontend to Backend | 8080 | 10.0.1.0/24 | Any | Allow |
| Backend | Allow RDP from Admin | 3389 | Admin Public IP | Any | Allow |
| Backend | Deny-All | Any | Any | Any | Deny |
| DB | Allow Backend to DB | 1433 | 10.0.2.0/24 | Any | Allow |
| DB | Deny-All | Any | Any | Any | Deny |

---

## Deployment Steps

1. **Create a resource group**
   ```bash
   az group create --name RG-LayiCorp-IT --location westeurope
   ```

2. **Deploy using the appropriate parameters file**
   ```bash
   az deployment group create \
     --resource-group RG-LayiCorp-IT \
     --template-file ./infra/main.bicep \
     --parameters @./infra/main.parameters.IT.json
   ```

   Repeat for HR or SM by using:
   ```bash
   --parameters @./infra/main.parameters.HR.json
   ```
   or  
   ```bash
   --parameters @./infra/main.parameters.SM.json
   ```

---

## Parameters Example (main.parameters.IT.json)

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "projectPrefix": { "value": "LayiCorp-IT" },
    "adminUsername": { "value": "LayiAdmin" },
    "adminPassword": { "value": "passwordHere!!" },
    "adminPublicIP": { "value": "yourPublicIPHere" }
  }
}
```

---

## Outputs

After deployment, confirm the outputs with:

```bash
az deployment group show -n main -g RG-LayiCorp-IT --query properties.outputs
```

Expected outputs include:

| Output Name | Description |
|:-------------|:-------------|
| vnetId | ID of the deployed virtual network |
| frontendVmId | ID of the Frontend VM |
| appVmId | ID of the Application VM |
| dbVmId | ID of the Database VM |

---

## Verification Screenshots

For validation and documentation, the following screenshots were captured during deployment:

1. Azure CLI deployment success output  
2. NSG inbound and outbound rules for each subnet  
3. Virtual Network showing all three subnets (Frontend, Backend, DB)  
4. VM overview pages showing all instances running (Frontend, App, DB)  
5. Public IP and DNS configuration for Frontend VM  

Screenshots are stored under `/screenshots/` for reference.

---

## Key Highlights

- Fully modular Infrastructure-as-Code built with Azure Bicep  
- Parameterized for multi-department scalability (IT, HR, SM)  
- Subnet isolation and NSG-based traffic control  
- Reusable templates and environment-specific configurations  
- Controlled RDP access restricted by public IP  
- Compatible with future integration for Key Vault, Bastion, and centralized monitoring  

---

## Next Steps

To extend this project toward enterprise-grade deployment:

1. Integrate Azure Key Vault for credential management  
2. Add Azure Monitor or Log Analytics for centralized monitoring  
3. Configure Azure Bastion for secure, agentless RDP access  
4. Implement VNet peering across departments if inter-communication is required  
5. Enforce role-based access control (RBAC) and tagging standards  

---

## Summary

This project demonstrates the use of Azure Bicep to build a scalable, secure, and modular infrastructure foundation.  
It provides a strong baseline for enterprise workloads and can easily be extended to include automation, monitoring, and advanced security components.
