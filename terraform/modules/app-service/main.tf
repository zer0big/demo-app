terraform {
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
      version = "1.2.6"
    }
  }
}

resource "azurecaf_name" "app_service_plan" {
  name            = var.application_name
  resource_type   = "azurerm_app_service_plan"
  suffixes        = [var.environment]
}

# This creates the plan that the service use
resource "azurerm_app_service_plan" "application" {
  name                = azurecaf_name.app_service_plan.result
  resource_group_name = var.resource_group
  location            = var.location

  kind     = "Linux"
  reserved = true

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
  }

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurecaf_name" "app_service" {
  name            = var.application_name
  resource_type   = "azurerm_app_service"
  suffixes        = [var.environment]
}

# This creates the service definition
resource "azurerm_app_service" "application" {
  name                = azurecaf_name.app_service.result
  resource_group_name = var.resource_group
  location            = var.location
  app_service_plan_id = azurerm_app_service_plan.application.id
  https_only          = true

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
  }

  site_config {
    linux_fx_version = "NODE|14-lts"
    app_command_line = "npm run start:prod"
    always_on        = true
    ftps_state       = "FtpsOnly"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "WEBSITE_RUN_FROM_PACKAGE"            = "1"
    "WEBSITE_NODE_DEFAULT_VERSION"        = "~14"

    # These are app specific environment variables
  }
}
