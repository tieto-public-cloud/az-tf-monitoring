# Declare some helpful locals, show examples of various customizations
# supported by these modules.
locals {
  # Some tags applied to all newly deployed resources.
  common_tags = merge(
    var.common_tags,
    var.monitored_tags # We want to monitor whatever we deploy here.
  )

  # For sandbox VMs.
  unsafe_user   = "adminuser"
  unsafe_passwd = "Azur3M33tupF3b!"
}

##############################################################################
## Set up sandbox infrastructure needed for this example.
##############################################################################

## LAW set-up.
resource "azurerm_resource_group" "law_rg" {
  name     = var.law_resource_group_name
  location = var.location

  tags     = local.common_tags
  provider = azurerm.law
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  location            = azurerm_resource_group.law_rg.location
  resource_group_name = azurerm_resource_group.law_rg.name

  retention_in_days = 30

  tags     = local.common_tags
  provider = azurerm.law
}

resource "azurerm_storage_account" "law_storage" {
  name                     = replace("${var.law_name}sa","/[^a-z0-9]/","")
  resource_group_name      = azurerm_resource_group.law_rg.name
  location                 = azurerm_resource_group.law_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags     = var.common_tags
  provider = azurerm.law
}

resource "azurerm_log_analytics_solution" "law_vminsights" {
  solution_name         = "VMInsights"
  location              = azurerm_resource_group.law_rg.location
  resource_group_name   = azurerm_resource_group.law_rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.law.id
  workspace_name        = var.law_name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/VMInsights"
  }

  provider = azurerm.law
}

## FA set-up.
resource "azurerm_resource_group" "fa_rg" {
  name     = var.fa_resource_group_name
  location = var.location

  tags     = local.common_tags
  provider = azurerm.aux
}

## Set up some VMs to create logs.
resource "azurerm_resource_group" "sb_rg" {
  name     = var.sb_resource_group_name
  location = var.location

  tags     = local.common_tags
  provider = azurerm.aux
}

resource "azurerm_virtual_network" "sb_vnet" {
  name                = "vnet-sandbox"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.sb_rg.location
  resource_group_name = azurerm_resource_group.sb_rg.name

  tags     = local.common_tags
  provider = azurerm.aux
}

resource "azurerm_subnet" "sb_linux" {
  name                 = "linux-sandbox"
  resource_group_name  = azurerm_resource_group.sb_rg.name
  virtual_network_name = azurerm_virtual_network.sb_vnet.name
  address_prefixes     = ["10.0.0.0/24"]

  provider = azurerm.aux
}

resource "azurerm_subnet" "sb_win" {
  name                 = "win-sandbox"
  resource_group_name  = azurerm_resource_group.sb_rg.name
  virtual_network_name = azurerm_virtual_network.sb_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  provider = azurerm.aux
}

resource "azurerm_network_security_group" "sb_nsg" {
  name                = "nsg-sandbox"
  location            = azurerm_resource_group.sb_rg.location
  resource_group_name = azurerm_resource_group.sb_rg.name

  tags     = local.common_tags
  provider = azurerm.aux
}

resource "azurerm_subnet_network_security_group_association" "sb_nsg_linux" {
  subnet_id                 = azurerm_subnet.sb_linux.id
  network_security_group_id = azurerm_network_security_group.sb_nsg.id

  provider = azurerm.aux
}

resource "azurerm_subnet_network_security_group_association" "sb_nsg_win" {
  subnet_id                 = azurerm_subnet.sb_win.id
  network_security_group_id = azurerm_network_security_group.sb_nsg.id

  provider = azurerm.aux
}

resource "azurerm_network_interface" "sb_linux_intf" {
  name                = "linux-nic"
  location            = azurerm_resource_group.sb_rg.location
  resource_group_name = azurerm_resource_group.sb_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sb_linux.id
    private_ip_address_allocation = "Dynamic"
  }

  tags     = local.common_tags
  provider = azurerm.aux
}

resource "azurerm_network_interface" "sb_win_intf" {
  name                = "win-nic"
  location            = azurerm_resource_group.sb_rg.location
  resource_group_name = azurerm_resource_group.sb_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sb_win.id
    private_ip_address_allocation = "Dynamic"
  }

  tags     = local.common_tags
  provider = azurerm.aux
}

resource "azurerm_linux_virtual_machine" "sb_linux" {
  name                = "linux-vm"
  resource_group_name = azurerm_resource_group.sb_rg.name
  location            = azurerm_resource_group.sb_rg.location
  size                = "Standard_F2"

  ## This is obviously unsafe, please do not use!
  admin_username                  = local.unsafe_user
  admin_password                  = local.unsafe_passwd
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.sb_linux_intf.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  tags     = local.common_tags
  provider = azurerm.aux
}

data "azurerm_monitor_diagnostic_categories" "sb_linux_cats" {
  resource_id = azurerm_linux_virtual_machine.sb_linux.id
  provider    = azurerm.aux
}

resource "azurerm_monitor_diagnostic_setting" "sb_linux_diag" {
  name                       = "linux-vm-diag"
  target_resource_id         = azurerm_linux_virtual_machine.sb_linux.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.sb_linux_cats.logs

    content {
      category = log.value
      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.sb_linux_cats.metrics

    content {
      category = metric.value
      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }

  provider = azurerm.aux
}

resource "azurerm_virtual_machine_extension" "sb_linux_omsext" {
  name                  = "OMSExtension"
  virtual_machine_id    = azurerm_linux_virtual_machine.sb_linux.id
  publisher             = "Microsoft.EnterpriseCloud.Monitoring"
  type                  = "OmsAgentForLinux"
  type_handler_version  = "1.12"

  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "workspaceId": "${azurerm_log_analytics_workspace.law.workspace_id}"
    }
  SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${azurerm_log_analytics_workspace.law.primary_shared_key}"
    }
  PROTECTED_SETTINGS

  tags     = local.common_tags
  provider = azurerm.aux
}

resource "azurerm_virtual_machine_extension" "sb_linux_da" {
  name                       = "DAExtension"
  virtual_machine_id         =  azurerm_linux_virtual_machine.sb_linux.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentLinux"
  type_handler_version       = "9.5"
  auto_upgrade_minor_version = true

  tags     = local.common_tags
  provider = azurerm.aux
}

resource "azurerm_windows_virtual_machine" "sb_win" {
  name                = "win-vm"
  resource_group_name = azurerm_resource_group.sb_rg.name
  location            = azurerm_resource_group.sb_rg.location
  size                = "Standard_F2"

  ## This is obviously unsafe, please do not use!
  admin_username = local.unsafe_user
  admin_password = local.unsafe_passwd

  network_interface_ids = [
    azurerm_network_interface.sb_win_intf.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  tags     = local.common_tags
  provider = azurerm.aux
}

data "azurerm_monitor_diagnostic_categories" "sb_win_cats" {
  resource_id = azurerm_windows_virtual_machine.sb_win.id
  provider    = azurerm.aux
}

resource "azurerm_monitor_diagnostic_setting" "sb_win_diag" {
  name                       = "win-vm-diag"
  target_resource_id         = azurerm_windows_virtual_machine.sb_win.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.sb_win_cats.logs

    content {
      category = log.value
      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.sb_win_cats.metrics

    content {
      category = metric.value
      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }

  provider = azurerm.aux
}

resource "azurerm_virtual_machine_extension" "sb_win_omsext" {
  name                  = "OMSExtension"
  virtual_machine_id    = azurerm_windows_virtual_machine.sb_win.id
  publisher             = "Microsoft.EnterpriseCloud.Monitoring"
  type                  = "MicrosoftMonitoringAgent"
  type_handler_version  = "1.0"

  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "workspaceId": "${azurerm_log_analytics_workspace.law.workspace_id}"
    }
  SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${azurerm_log_analytics_workspace.law.primary_shared_key}"
    }
  PROTECTED_SETTINGS

  tags     = local.common_tags
  provider = azurerm.aux
}

resource "azurerm_virtual_machine_extension" "sb_win_da" {
  name                       = "DAExtension"
  virtual_machine_id         =  azurerm_windows_virtual_machine.sb_win.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.5"
  auto_upgrade_minor_version = true

  tags     = local.common_tags
  provider = azurerm.aux
}

##############################################################################
## Monitoring set-up with alerts
##############################################################################

module "monitoring" {
  ## !!WARN!!
  ##
  ## The `source` parameter must be changed when you are using it in your own code!
  ##
  ## Use:
  ##   "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/monitoring?ref=v2.0"
  ## where `v2.0` is a git repository reference to a tagged version of the code (a git tag).
  ##
  ## This will make sure your module is correctly versioned and its code is retrieved from the correct place.
  ##
  ## !!WARN!!
  source    = "./modules/monitoring"

  ## The module expects a specific provider, mapping must be provided explicitly!
  providers = {
    azurerm = azurerm.law
  }

  ## Location must be shared by all resources, only regional deployments are supported.
  location  = var.location

  ## Which Log Analytics Workspace will be used as the source of data. It must exist beforehand!
  law_name                = var.law_name
  law_resource_group_name = azurerm_resource_group.law_rg.name

  ## Change configuration of the default action group set up.
  ## Module deploys two webhook-based AGs by default:
  ## * tm-critical-actiongroup
  ## * tm-warning-actiongroup
  ag_default_webhook_service_uri = var.snow_webhook_uri
  # ag_default_use_common_alert_schema = true

  ## To choose what will be monitored. Everything is turned off by default.
  monitor = [
    "azurevm",
    # "azuresql",
    # "backup",
    # "agw",
    # "azurefunction",
    # "datafactory",
    # "expressroute",
    # "lb",
    "tagging_functionapp" ## To monitor resources deployed by this module.
  ]

  ## Assign common tags to all resources deployed by this module and its submodules.
  common_tags = local.common_tags

  ############################################################################
  ## Everything beyond this point is customization for experts.
  ############################################################################

  ## Add any new action groups referenced from custom signals below here!
  # action_groups  = []

  ## Take care to reference only existing action groups (or add them above)!
  # azurevm_log_signals       = []
  # azuresql_log_signals      = []
  # logicapp_log_signals      = []
  # backup_log_signals        = []
  # agw_log_signals           = []
  # azurefunction_log_signals = []
  # datafactory_log_signals   = []
  # expressroute_log_signals  = []
  # lb_log_signals            = []

  ## Take care to reference only existing action groups (or add them above)!
  # metric_signals = []

  ############################################################################
  ## This part is necessary only for the example, we need to
  ## wait for LAW to be created before we start deploying monitoring.
  ############################################################################
  depends_on = [
    azurerm_log_analytics_workspace.law
  ]
}

##############################################################################
## Tagging Function App(s)
##############################################################################

# Deploy Function App(s) pulling resource tags and sending them to the Log Analytics Workspace.
# One FApp per target subscription.
module "tagging_functionapp" {
  count = length(var.target_subscription_ids)

  ## !!WARN!!
  ##
  ## The `source` parameter must be changed when you are using it in your own code!
  ##
  ## Use:
  ##   "git::https://github.com/tieto-public-cloud/az-tf-monitoring//modules/tagging_functionapp?ref=v2.0"
  ## where `v2.0` is a git repository reference to a tagged version of the code (a git tag).
  ##
  ## This will make sure your module is correctly versioned and its code is retrieved from the correct place.
  ##
  ## !!WARN!!
  source    = "./modules/tagging_functionapp"

  ## The module expects a specific provider, mapping must be provided explicitly!
  providers = {
    azurerm = azurerm.aux
  }

  ## Name the function(s) and provide a resource group to use.
  ## An index is appended to every name, resource group remains the same.
  name                = "${var.fa_name}${count.index}"
  resource_group_name = azurerm_resource_group.fa_rg.name

  ## Azure is picky about SA names, be sure to provide a valid value here!
  storage_account_name = replace("${var.fa_name}${count.index}sa","/[^a-z0-9]/","")

  location                = var.location
  law_name                = var.law_name
  law_resource_group_name = azurerm_resource_group.law_rg.name
  law_id                  = azurerm_log_analytics_workspace.law.id

  ## Provide a subscription from which to read resource tags.
  target_subscription_id = var.target_subscription_ids[count.index]

  ## During the deployment, we need to adjust Azure RBAC assignments.
  ## If your deployment credentials don't have permission to do that,
  ## set this to `false` and look for principal IDs in the output so
  ## that you can assign roles manually.
  ##
  ## Look for:
  ## * principal_id             (this is the identity that needs roles below)
  ## * storage_account_id       (Storage Account Contributor)
  ## * law_id                   (Log Analytics Contributor)
  ## * target_subscription_id   (Reader)
  ##
  # assign_roles = true

  ## Assign common tags to all resources deployed by this module and its submodules.
  common_tags = local.common_tags

  ############################################################################
  ## Everything beyond this point is customization for experts.
  ############################################################################

  ## How often should helper function refresh data from target subscriptions?
  ## Doing this often can get expensive. Do not change this value unless you
  ## know what you are doing.
  # tag_retrieval_interval = 3600

  ############################################################################
  ## This part is necessary only for the example, we need to
  ## wait for LAW to be created before we start deploying monitoring.
  ############################################################################
  depends_on = [
    azurerm_resource_group.fa_rg,
    azurerm_log_analytics_workspace.law
  ]
}
