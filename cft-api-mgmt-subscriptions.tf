# Subscription keys for the CFT APIM

# Internal subscription - Fee and Payment DTS Team
resource "azurerm_api_management_subscription" "fee_pay_team_payment_subscription" {
  api_management_name = local.cft_api_mgmt_name
  resource_group_name = local.cft_api_mgmt_rg
  product_id          = module.cft_api_mgmt_product.id
  display_name        = "Payment API - Fee and Pay DTS Team Subscription"
  state               = "active"
  provider            = azurerm.aks-cftapps
}

resource "azurerm_key_vault_secret" "fee_pay_team_payment_subscription_key" {
  name         = "fee-pay-team-payment-cft-apim-subscription-key"
  value        = azurerm_api_management_subscription.fee_pay_team_payment_subscription.primary_key
  key_vault_id = data.azurerm_key_vault.payment_key_vault.id
}

# Supplier subscription - Liberata
resource "azurerm_api_management_subscription" "liberata_supplier_payment_subscription" {
  api_management_name = local.cft_api_mgmt_name
  resource_group_name = local.cft_api_mgmt_rg
  product_id          = module.cft_api_mgmt_product.id
  display_name        = "Payment API - Liberata Subscription"
  state               = "active"
  provider            = azurerm.aks-cftapps
}

resource "azurerm_key_vault_secret" "liberata_supplier_payment_subscription_key" {
  name         = "liberata-cft-apim-payment-subscription-key"
  value        = azurerm_api_management_subscription.liberata_supplier_payment_subscription.primary_key
  key_vault_id = data.azurerm_key_vault.payment_key_vault.id
}
