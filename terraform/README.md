\# Azure MongoDB Replica Set Infrastructure



\## Overview



Terraform configuration for provisioning the Azure infrastructure used by the MongoDB replica set lab.



\## Architecture



| VM | Role | VM Size | Private IP |

|---|---|---|---|

| host01 | Administration and backup server | Standard\_F1as\_v7 | 10.20.1.10 |

| mongo01 | Preferred primary | Standard\_D2as\_v7 | 10.20.1.11 |

| mongo02 | Secondary | Standard\_D2as\_v7 | 10.20.1.12 |

| mongo03 | Secondary | Standard\_D2as\_v7 | 10.20.1.13 |

| mongo04 | Arbiter | Standard\_F1as\_v7 | 10.20.1.14 |



\## Azure Network



\- Region: East US 2

\- Resource group: rg-mongodb-replica

\- Virtual network: vnet-mongodb

\- VNet address space: 10.20.0.0/16

\- Subnet: snet-mongodb

\- Subnet address space: 10.20.1.0/24



\## Security



\- SSH access restricted to the administrator public IP.

\- MongoDB port 27017 allowed within the virtual network.

\- Only host01 has a public IP.

\- Linux VM authentication uses SSH public keys.

\- MongoDB authentication and replica set keyfile configuration are managed separately from Terraform.



\## Prerequisites



\- Terraform 1.5 or later

\- Azure CLI

\- Azure subscription

\- Existing Azure resource group

\- SSH key pair



\## Authentication



```bash

az login

az account set --subscription YOUR-AZURE-SUBSCRIPTION-ID

```



\## Configuration



Copy the example variables file:



```bash

cp terraform.tfvars.example terraform.tfvars

```



Edit terraform.tfvars with your subscription ID, administrator public IP CIDR, and SSH public key path.



\## Deployment



```bash

terraform init

terraform fmt -check

terraform validate

terraform plan -out=mongodb-infrastructure.tfplan

terraform apply mongodb-infrastructure.tfplan

```



View outputs:



```bash

terraform output

```



\## Destroy Infrastructure



Review the destruction plan:



```bash

terraform plan -destroy

```



Destroy the lab when it is no longer required:



```bash

terraform destroy

```



\## Important Notes



\- The resource group must exist before deployment.

\- Never commit Terraform state or plan files.

\- Never commit SSH private keys, MongoDB credentials, or Azure secrets.

\- Review Azure VM pricing and regional availability before deployment.

\- MongoDB installation and replica set configuration are managed separately from Terraform.

