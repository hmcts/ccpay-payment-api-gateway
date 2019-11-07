module "ccpay-telephony-product" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-product?ref=master"

  api_mgmt_name = "core-api-mgmt-demodata"
  api_mgmt_rg   = "core-infra-demodata-rg"

  name = "telephony"
}

module "ccpay-telephony-api" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-api?ref=master"

  api_mgmt_name = "core-api-mgmt-demodata"
  api_mgmt_rg   = "core-infra-demodata-rg"

  revision     = "1"
  product_id   = "${module.ccpay-telephony-product.product_id}"
  name         = "telephony-api"
  display_name = "Telephony API"
  path         = "telephony-api"
  swagger_url  = "https://raw.githubusercontent.com/hmcts/reform-api-docs/master/docs/specs/ccpay-payment-app.telephony.json"
}

// TODO, look at why this is generating a new template each time
data "template_file" "telephony_policy_template" {
  template = "${file("${path.module}/templates/ccpay-telephony-api-policy.xml")}"

  vars {
    allowed_certificate_thumbprints = "${local.telephony_thumbprints_in_quotes_str}"
    s2s_client_id                   = "${data.azurerm_key_vault_secret.s2s_client_id.value}"
    s2s_client_secret               = "${data.api_gateway_s2s_dummy_secret}"
    s2s_base_url                    = "${data.s2s_base_url}"
  }
}

module "ccpay-telephony-policy" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-api-policy?ref=master"

  api_mgmt_name = "core-api-mgmt-demodata"
  api_mgmt_rg   = "core-infra-demodata-rg"

  api_name               = "${module.ccpay-telephony-api.name}"
  api_policy_xml_content = "${data.template_file.telephony_policy_template.rendered}"
}
