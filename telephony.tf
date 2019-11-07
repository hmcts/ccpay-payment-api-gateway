module "ccpay-telephony-product" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-product?ref=master"
  api_mgmt_name = "core-api-mgmt-${var.env}"
  api_mgmt_rg   = "core-infra-${var.env}"

  name = "telephony"
}

module "ccpay-telephony-api" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-api?ref=master"

  api_mgmt_name = "core-api-mgmt-${var.env}"
  api_mgmt_rg   = "core-infra-${var.env}"
  revision      = "1"
  product_id    = "${module.ccpay-telephony-product.product_id}"
  name          = "telephony-api"
  display_name  = "Telephony API"
  path          = "telephony-api"
  swagger_url   = "https://raw.githubusercontent.com/hmcts/reform-api-docs/master/docs/specs/ccpay-payment-app.telephony.json"
}

// TODO, look at why this is generating a new template each time
data "template_file" "telephony_policy_template" {
  template = "${file("${path.module}/templates/ccpay-telephony-api-policy.xml")}"

  vars {
    allowed_certificate_thumbprints = "${local.telephony_thumbprints_in_quotes_str}"
    s2s_client_id                   = "${data.azurerm_key_vault_secret.s2s_client_id.value}"
    s2s_client_secret               = "${data.azurerm_key_vault_secret.s2s_client_secret.value}"
    s2s_base_url                    = "${local.s2sUrl}"
    service_url                     = "${local.payments_api_url}"
  }
}

module "ccpay-telephony-policy" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-api-policy?ref=master"

  api_mgmt_name = "core-api-mgmt-${var.env}"
  api_mgmt_rg   = "core-infra-${var.env}"

  api_name               = "${module.ccpay-telephony-api.name}"
  api_policy_xml_content = "${data.template_file.telephony_policy_template.rendered}"
}
