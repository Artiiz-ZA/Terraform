output "admin_password" {
  description = "Password for admin on the sql server."
  value = random_string.password.result
  sensitive = true
}

output "sql_server_name" {
  description = "Name of the server created. Use this if more databases needs to be added to the server. "
  value = azurerm_sql_server.sql_server.name
}

output "sql_server_id" {
  description = "Id of Azure SQL Server created."
  value = azurerm_sql_server.sql_server.id
}

output "sql_database_id" {
  description = "Id of Azure SQL database created."
  value = azurerm_sql_database.sql_database.id
}

output "connection_string" {
  description = "Connection string for the Azure SQL Database created."
  value       = "Server=tcp:${azurerm_sql_server.sql_server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.sql_database.name};Persist Security Info=False;User ID=${azurerm_sql_server.sql_server.administrator_login};Password=replace-with-password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}