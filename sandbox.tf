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

## LA set-up.
resource "azurerm_resource_group" "la_rg" {
  name     = var.la_resource_group_name
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
