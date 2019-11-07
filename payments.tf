module "ccpay-payments-product" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-product?ref=master"

  api_mgmt_name = "core-api-mgmt-${var.env}"
  api_mgmt_rg   = "core-infra-${var.env}"
  subscription_required = false
  approval_required     = false
  subscriptions_limit   = "0"

  name = "payments"
}

module "ccpay-payments-api" {
  source        = "git@github.com:hmcts/cnp-module-api-mgmt-api?ref=master"
  api_mgmt_name = "core-api-mgmt-${var.env}"
  api_mgmt_rg   = "core-infra-${var.env}"

  revision     = "1"
  product_id   = "${module.ccpay-payments-product.product_id}"
  name         = "payments-api"
  display_name = "Payments API"
  path         = "payments-api"
  swagger_url  = "https://raw.githubusercontent.com/hmcts/reform-api-docs/master/docs/specs/ccpay-payment-app.payments.json"
}

// TODO, look at why this is generating a new template each time
data "template_file" "payments_policy_template" {
  template = "${file("${path.module}/templates/ccpay-payments-api-policy.xml")}"

  vars {
    allowed_certificate_thumbprints = "${local.payments_thumbprints_in_quotes_str}"
    s2s_client_id                   = "${data.azurerm_key_vault_secret.s2s_client_id.value}"
    s2s_client_secret               = "${data.azurerm_key_vault_secret.s2s_client_secret.value}"
    s2s_base_url                    = "${data.s2s_base_url}"
  }
}

module "ccpay-payments-policy" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-api-policy?ref=master"

  api_mgmt_name = "core-api-mgmt-${var.env}"
  api_mgmt_rg   = "core-infra-${var.env}"

  api_name               = "${module.ccpay-payments-api.name}"
  api_policy_xml_content = "${data.template_file.payments_policy_template.rendered}"
}
