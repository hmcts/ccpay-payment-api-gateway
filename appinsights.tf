#resource "azurerm_key_vault_secret" "app_insights_connection_string" {
  #name         = "app-insights-connection-string"
 # value        = azurerm_application_insights.appinsights.connection_string
  #key_vault_id = module.send-letter-key-vault.key_vault_id
#}

resource "azurerm_application_insights" "appinsights" {
  name                = "${var.product}-${var.component}-appinsights-${var.env}"
  location            = var.appinsights_location
  resource_group_name = local.api_mgmt_rg
  application_type    = var.application_type
  tags                = var.common_tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to appinsights as otherwise upgrading to the Azure provider 2.x
      # destroys and re-creates this appinsights instance
      application_type,
    ]
  }
}
