variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure deployment region"
  type        = string
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Existing Azure resource group"
  type        = string
  default     = "rg-mongodb-replica"
}

variable "vnet_name" {
  description = "MongoDB virtual network name"
  type        = string
  default     = "vnet-mongodb"
}

variable "vnet_address_space" {
  description = "Virtual network address space"
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "subnet_name" {
  description = "MongoDB subnet name"
  type        = string
  default     = "snet-mongodb"
}

variable "subnet_address_prefixes" {
  description = "MongoDB subnet address range"
  type        = list(string)
  default     = ["10.20.1.0/24"]
}

variable "tags" {
  description = "Common Azure resource tags"
  type        = map(string)

  default = {
    Project     = "MongoDB-Replica-Set"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

variable "admin_ip_cidr" {
  description = "Public IP allowed to access SSH"
  type        = string
}

variable "admin_username" {
  description = "Linux administrator username"
  type        = string
  default     = "sysadmin"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
