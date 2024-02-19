# #############################################################################
#                          Modules
# #############################################################################

module "azure_regions" {
  source = "github.com/TaleLearnCode/terraform-azure-regions"
  azure_region = var.azure_region
}

module "resource_group" {
  source = "github.com/TaleLearnCode/azure-resource-types"
  resource_type = "resource-group"
}

module "storage_account" {
  source = "github.com/TaleLearnCode/azure-resource-types"
  resource_type = "storage-account"
}


module "key_vault" {
  source = "github.com/TaleLearnCode/azure-resource-types"
  resource_type = "key-vault"
}

# #############################################################################
#                             Local Variables
# #############################################################################

locals {
  tags = {
    Product      = var.product
    Criticiality = var.tag_criticiality
    DR           = var.tag_disaster_recovery
    Env          = var.azure_environment
  }
}

# #############################################################################
#                       AzureRM Provider Configuration
# #############################################################################

data "azurerm_client_config" "current" {}

# #############################################################################
#                           Resource Group
# #############################################################################

resource "azurerm_resource_group" "terraform" {
  name     = "${module.resource_group.name.abbreviation}-${var.product}-${var.azure_environment}-${module.azure_regions.region.region_short}"
  location = module.azure_regions.region.region_cli
  tags     = local.tags
}

# #############################################################################
#                           Storage Account
# #############################################################################

resource "azurerm_storage_account" "terraform" {
  name                            = lower("${module.storage_account.name.abbreviation}${var.product}${var.azure_environment}${module.azure_regions.region.region_short}")
  resource_group_name             = azurerm_resource_group.terraform.name
  location                        = azurerm_resource_group.terraform.location
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.storage_account_replication_type
  allow_nested_items_to_be_public = false

  tags = local.tags
}

resource "azurerm_storage_container" "remote_state" {
  name                 = "terraform-state"
  storage_account_name = azurerm_storage_account.terraform.name
}

data "azurerm_storage_account_sas" "state" {
  connection_string = azurerm_storage_account.terraform.primary_connection_string
  https_only        = true

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "17520h")

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

# #############################################################################
#                           Key Vault
# #############################################################################

resource "azurerm_key_vault" "terraform" {
  name                        = "${module.key_vault.name.abbreviation}-${var.product}-${var.azure_environment}-${module.azure_regions.region.region_short}"
  location                    = azurerm_resource_group.terraform.location
  resource_group_name         = azurerm_resource_group.terraform.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = var.key_vault_sku_name
  enable_rbac_authorization  = true
}

# #############################################################################
#                           backend-config.txt
# #############################################################################

resource "local_file" "backend-config" {
  depends_on = [azurerm_storage_container.remote_state]

  filename = "${path.module}/backend-config.txt"
  content  = <<-EOF
storage_account_name = "${azurerm_storage_account.terraform.name}"
container_name = "terraform-state"
key = "terraform.tfstate"
sas_token = "${data.azurerm_storage_account_sas.state.sas}"
  EOF
}