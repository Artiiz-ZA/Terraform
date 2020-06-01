# Azure SQL Server

## Creates a SQL server with Database
Terraform module for Azure to create a SQL server with initial database and Azure AD login. 

A SQL server has to have a sql administrator login, so this will be generated in the package. It generates a 32 character long random password for the login. This password is outputed and stored in the state file, so make sure your state file is secure. Read more about sensitive data in state here: https://www.terraform.io/docs/state/sensitive-data.html

Installs following resources:
- SQL Server
- SQL Database
- Active Directory Administrator

Optionally installs following: 
- Firewall rule for azure ip ranges. 

## Usage

```hcl

resource "azurerm_resource_group" "sql_rg" {
  name     = "sql-rg"
  location = "southafricanorth"
}

module "sql_server" {
  source = "../"

  server_name           = "{name}-sql-server"
  database_name         = "settings"
  allow_azure_ip_access = true

  resource_group_name = azurerm_resource_group.sql_rg.name
  location            = "southafricanorth"
  environment         = "dev"
  release             = "release 2018-07-21.001"

  # SQL login admin
  admin_login_name = "super_awesome_admin_username"

  # AAD login admin
  ad_admin_login_name = "sql-admin@{yourcompany}.com"
  ad_admin_tenant_id  = "{AzureAD-TenantID}"
  ad_admin_object_id  = "{AzureAD-AdminObjectID}"

  # Scaling
  database_edition                          = "Standard"
  database_requested_service_objective_name = "S3"

  database_collation = "SQL_LATIN1_GENERAL_CP1_CI_AS"

  tags {
      a       = "b",
      project = "{yourproject}"
      
  }
}

```