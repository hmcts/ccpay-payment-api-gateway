provider "azurerm" {
  features {}
}

locals {
  api_mgmt_name     = join("-", ["core-api-mgmt", var.env])
  api_mgmt_rg       = join("-", ["core-infra", var.env])
  payment_key_vault = join("-", ["ccpay", var.env])
  api_base_path     = "payments-api"

  payments_api_url = join("", ["http://payment-api-", var.env, ".service.core-compute-", var.env, ".internal"])
  s2sUrl           = join("", ["http://rpe-service-auth-provider-", var.env, ".service.core-compute-", var.env, ".internal"])

  # list of the thumbprints of the SSL certificates that should be accepted by the API (gateway)
  thumbprints_in_quotes     = formatlist("\"%s\"", var.api_gateway_test_certificate_thumbprints)
  thumbprints_in_quotes_str = join(",", local.thumbprints_in_quotes)

    api_mgmt_name_cft        = join("-", ["cft-api-mgmt", var.env])
    api_mgmt_rg_cft          = join("-", ["cft", var.env, "network-rg"])
}

data "azurerm_key_vault" "payment_key_vault" {
  name                = local.payment_key_vault
  resource_group_name = local.payment_key_vault
}

data "azurerm_key_vault_secret" "s2s_client_secret" {
  name         = "gateway-s2s-client-secret"
  key_vault_id = data.azurerm_key_vault.payment_key_vault.id
}

data "azurerm_key_vault_secret" "s2s_client_id" {
  name         = "gateway-s2s-client-id"
  key_vault_id = data.azurerm_key_vault.payment_key_vault.id
}

module "api_mgmt_product" {
  source        = "git@github.com:hmcts/cnp-module-api-mgmt-product?ref=master"
  name          = var.product_name
  api_mgmt_name = local.api_mgmt_name
  api_mgmt_rg   = local.api_mgmt_rg
}

module "api_mgmt_api" {
  source        = "git@github.com:hmcts/cnp-module-api-mgmt-api?ref=master"
  name          = join("-", [var.product_name, "api"])
  display_name  = "Payments API"
  api_mgmt_name = local.api_mgmt_name
  api_mgmt_rg   = local.api_mgmt_rg
  product_id    = module.api_mgmt_product.product_id
  path          = local.api_base_path
  service_url   = local.payments_api_url
  swagger_url   = "https://raw.githubusercontent.com/hmcts/reform-api-docs/master/docs/specs/ccpay-payment-app.recon-payments.json"
  revision      = "1"
}

data "template_file" "policy_template" {
  template = file(join("", [path.module, "/template/api-policy.xml"]))

  vars = {
    allowed_certificate_thumbprints = local.thumbprints_in_quotes_str
    s2s_client_id                   = data.azurerm_key_vault_secret.s2s_client_id.value
    s2s_client_secret               = data.azurerm_key_vault_secret.s2s_client_secret.value
    s2s_base_url                    = local.s2sUrl
  }
}

module "api_mgmt_policy" {
  source                 = "git@github.com:hmcts/cnp-module-api-mgmt-api-policy?ref=master"
  api_mgmt_name          = local.api_mgmt_name
  api_mgmt_rg            = local.api_mgmt_rg
  api_name               = module.api_mgmt_api.name
  api_policy_xml_content = data.template_file.policy_template.rendered
}

module "ccpay-payment-product" {
  source                        = "git@github.com:hmcts/cnp-module-api-mgmt-product?ref=master"
  api_mgmt_name                 = local.api_mgmt_name_cft
  api_mgmt_rg                   = local.api_mgmt_rg_cft
  name                          = var.product_name
  product_access_control_groups = ["developers"]

  providers = {
    azurerm = azurerm.cftappsdemo
  }
}
  
  data "azurerm_api_management_product" "paymentcft" {
  product_id          = module.ccpay-payment-product.product_id
  api_management_name = local.api_mgmt_name_cft
  resource_group_name = local.api_mgmt_rg_cft
  provider            = azurerm.cftappsdemo
}

module "ccpay-payment-api" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-api?ref=master"

  api_mgmt_name = local.api_mgmt_name_cft
  api_mgmt_rg   = local.api_mgmt_rg_cft
  revision      = "1"
  service_url   = local.payments_api_url
  product_id    = module.ccpay-payment-product.product_id
  name          = join("-", [var.product_name, "apiList"])
  protocols     = ["https"]
  display_name  = "Payments API"
  path          = local.api_base_path
  swagger_url   = "https://raw.githubusercontent.com/hmcts/reform-api-docs/master/docs/specs/ccpay-payment-app.payment-status.json"

  providers = {
    azurerm = azurerm.cftappsdemo
  }
}

module "ccpay-payment-policy" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-api-policy?ref=master"

  api_mgmt_name = local.api_mgmt_name_cft
  api_mgmt_rg   = local.api_mgmt_rg_cft

  api_name               =  module.ccpay-payment-api.name
  api_policy_xml_content = data.template_file.policy_template.rendered

  providers = {
    azurerm = azurerm.cftappsdemo
  }
 }
    
  
resource "azurerm_api_management_user" "payment_Ranjeet" {
  api_management_name = local.api_mgmt_name_cft
  resource_group_name = local.api_mgmt_rg_cft
  user_id             = "5931a75ae4bbd512288c990c"
  first_name          = "Ranjeet"
  last_name           = "Kumar"
  email               = "ranjeet.kumar@hmcts.net"
  state               = "active"

  provider = azurerm.cftappsdemo
}
resource "azurerm_api_management_user" "payment_sayali" {
  api_management_name = local.api_mgmt_name_cft
  resource_group_name = local.api_mgmt_rg_cft
  user_id             = "5931a75ae4bbd512288c790c"
  first_name          = "Sayali"
  last_name           = "Salunkhe"
  email               = "sayali.salunkhe@hmcts.net"
  state               = "active"
  provider = azurerm.cftappsdemo
}
  
  resource "azurerm_api_management_subscription" "sayali_sub_payment" {
  api_management_name = local.api_mgmt_name_cft
  resource_group_name = local.api_mgmt_rg_cft
  user_id             = azurerm_api_management_user.payment_sayali.id
  product_id          = data.azurerm_api_management_product.paymentcft.id
  display_name        = "payment Subscription sayali"
  state               = "active"
  provider = azurerm.cftappsdemo
}
  
  resource "azurerm_api_management_subscription" "Ranjeet_sub_payment" {
  api_management_name = local.api_mgmt_name_cft
  resource_group_name = local.api_mgmt_rg_cft
  user_id             = azurerm_api_management_user.payment_Ranjeet.id
  product_id          = data.azurerm_api_management_product.paymentcft.id
  display_name        = "payment Subscription ranjeet"
  state               = "active"
  provider = azurerm.cftappsdemo
}
  
  data "azurerm_api_management_user" "anshika" {
  user_id             = "5931a75ae4bbd512288c680b"
  api_management_name = local.api_mgmt_name_cft
  resource_group_name = local.api_mgmt_rg_cft
  provider            = azurerm.cftappsdemo
}
  
  
  resource "azurerm_api_management_subscription" "anshika_sub" {
  api_management_name = local.api_mgmt_name_cft
  resource_group_name = local.api_mgmt_rg_cft
  user_id             = data.azurerm_api_management_user.anshika.id
  product_id          = data.azurerm_api_management_product.paymentcft.id
  display_name        = "Payment Subscription"
  state               = "active"
  provider            = azurerm.cftappsdemo
}

resource "azurerm_api_management_user" "payment_Vamshi" {
  api_management_name = local.api_mgmt_name_cft
  resource_group_name = local.api_mgmt_rg_cft
  user_id             = "5931a75ae4bbd512288c991c"
  first_name          = "Vamshi"
  last_name           = "Rudrabhatla"
  email               = "vamshi.rudrabhatla@HMCTS.NET"
  state               = "active"

  provider = azurerm.cftappsdemo
}
 
resource "azurerm_api_management_subscription" "Vamshi_sub_payment" {
  api_management_name = local.api_mgmt_name_cft
  resource_group_name = local.api_mgmt_rg_cft
  user_id             = azurerm_api_management_user.payment_Vamshi.id
  product_id          = data.azurerm_api_management_product.paymentcft.id
  display_name        = "payment Subscription Vamshi"
  state               = "active"
  provider = azurerm.cftappsdemo
}