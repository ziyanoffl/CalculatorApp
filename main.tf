# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

#Creating resource group
resource "azurerm_resource_group" "devopsprojectb" {
  name     = "devopsprojectb"
  location = "East US"
}

resource "azurerm_container_registry" "devopsprojectb" {
  name                = "devopsprojectb"
  resource_group_name = azurerm_resource_group.devopsprojectb.name
  location            = "East US"
  sku                 = "Standard"
  admin_enabled       = true
}

# resource "azurerm_role_assignment" "devopsprojectc" {
#   scope                = azurerm_container_registry.devopsprojectc.id
#   role_definition_name = "acrpull"
#   principal_id         = azurerm_app_service.devopsprojectc.identity[0].principal_id
# }

resource "azurerm_app_service_plan" "ASP-devopsprojectb-9277" {
  name                = "ASP-devopsprojectb-9277"
  location            = "East US"
  kind                = "linux"
  reserved            = true
  resource_group_name = azurerm_resource_group.devopsprojectb.name

  sku {
    tier = "Free"
    size = "F1"
  }
  timeouts {}
}

resource "azurerm_app_service" "devopsprojectapp" {
  name                = "devopsprojectapp"
  location            = "East US"
  resource_group_name = azurerm_resource_group.devopsprojectb.name
  app_service_plan_id = azurerm_app_service_plan.ASP-devopsprojectb-9277.id

  site_config {
    always_on = false
    default_documents = [
      "Default.htm",
      "Default.html",
      "Default.asp",
      "index.htm",
      "index.html",
      "iisstart.htm",
      "default.aspx",
      "index.php",
      "hostingstart.html",
    ]
    use_32_bit_worker_process = true
  }
  https_only = true

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL          = "https://${azurerm_container_registry.devopsprojectb.name}.azurecr.io"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    DOCKER_REGISTRY_SERVER_USERNAME     = azurerm_container_registry.devopsprojectb.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = "a60L7deektrSmbPwTIDHIBVHVKnYWqcb6gMghPXXUQ+ACRC66OaY"
    WEBSITES_PORT                       = "8080"
  }
  timeouts {}
}
