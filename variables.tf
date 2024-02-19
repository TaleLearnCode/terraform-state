#############################################################################
# Azure Authenication
#############################################################################

variable "azure_subscription_id" {
	type        = string
	description = "Identifier of the Azure subscription where Terraform should create the configured resources."
}

#############################################################################
# Environmental Variables
#############################################################################

variable "azure_region" {
	type        = string
	default     = "eastus2"
	description = "Location of the resource group."
}

variable "azure_environment" {
	type        = string
	default     = "Core"
	description = "The environment component of an Azure resource name. Valid values are dev, qa, e2e, core, and prod."
}

# #############################################################################
# Product Variables
# #############################################################################

variable "product" {
	type        = string
	default     = "Terraform"
	description = "The name of the product or service that the resources are being created for."
}

variable "product_area" {
	type        = string
	default     = ""
	description = "The product area of the product or service."
}

###############################################################################
# Tag values
###############################################################################

variable "tag_cost_center" {
	type        = string
	default     = "Core"
	description = "Accounting cost center associated with the resource."
}

variable "tag_criticiality" {
	type        = string
	default     = "Medium"
	description = "The business impact of the resource or supported workload. Valid values are Low, Medium, High, Business Unit Critical, Mission Critical."
}

variable "tag_disaster_recovery" {
	type        = string
	default     = "Dev"
	description = "Business criticality of the application, workload, or service. Valid values are Mission Critical, Critical, Essential, Dev."
}

# #############################################################################
# Storage Account Variables
# #############################################################################

variable "storage_account_tier" {
	type        = string
	default     = "Standard"
	description = "The storage account tier. Valid values are Standard and Premium."
}

variable "storage_account_replication_type" {
	type        = string
	default     = "LRS"
	description = "The storage account replication type. Valid values are LRS, GRS, RAGRS, ZRS, and GZRS."
}

# #############################################################################
# KeyVault Variables
# #############################################################################

variable "key_vault_sku_name" {
	type        = string
	default     = "standard"
	description = "The SKU name of the Key Vault to create. Valid values are standard and premium."
}