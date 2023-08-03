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

resource "azurerm_container_registry" "appcr" {
  name                    = "appcr"
  resource_group_name     = azurerm_resource_group.devopsprojectb.name
  location                = "East US"
  sku                     = "Premium"
  admin_enabled           = true
  zone_redundancy_enabled = true
  georeplications {
    location                  = "eastasia"
    regional_endpoint_enabled = true
    tags                      = {}
    zone_redundancy_enabled   = true
  }

  timeouts {}
}

resource "azurerm_app_service_plan" "appservice" {
  name                = "appservice"
  location            = "East US"
  kind                = "linux"
  reserved            = true
  resource_group_name = azurerm_resource_group.devopsprojectb.name

  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }
  zone_redundant = false
  timeouts {}
}

resource "azurerm_app_service" "calculatorwebapp" {
  name                = "calculatorwebapp"
  location            = "East US"
  resource_group_name = azurerm_resource_group.devopsprojectb.name
  app_service_plan_id = azurerm_app_service_plan.appservice.id

  site_config {
    always_on                = false
    ftps_state               = "FtpsOnly"
    ip_restriction           = []
    # linux_fx_version         = "DOCKER|appcr.azurecr.io/appcr/calculatorapp:185e39c35a0f0a5085bc5fa428b58e77dbc3ce22"
    local_mysql_enabled      = false
    managed_pipeline_mode    = "Integrated"
    min_tls_version          = "1.2"
    number_of_workers        = 1
    remote_debugging_version = "VS2019"
    scm_ip_restriction       = []
    vnet_route_all_enabled   = false
    websockets_enabled       = false
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
    health_check_path         = "/"
  }
  https_only = true

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL          = "https://${azurerm_container_registry.appcr.name}.azurecr.io"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    DOCKER_REGISTRY_SERVER_USERNAME     = azurerm_container_registry.appcr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = "LSrXwaiUbuCU5+XHnSQyLt9aeOLaRa/b7XqqsMXg/X+ACRCEoc34"
    WEBSITES_PORT                       = "8080"
    WEBSITE_HEALTHCHECK_MAXPINGFAILURES = "10"
  }
  timeouts {}
}
