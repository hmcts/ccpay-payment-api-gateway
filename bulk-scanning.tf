module "ccpay-bulkscanning-product" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-product?ref=master"

  api_mgmt_name         = "core-api-mgmt-demodata"
  api_mgmt_rg           = "core-infra-demodata-rg"

  name = "bulk-scanning-payment"
}

module "ccpay-bulkscanning-api" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-api?ref=master"

  api_mgmt_name = "core-api-mgmt-demodata"
  api_mgmt_rg   = "core-infra-demodata-rg"

  revision     = "1"
  product_id   = "${module.ccpay-bulkscanning-product.product_id}"
  name         = "bulk-scanning-payment-api"
  display_name = "bulk-scanning payments API"
  path         = "bulk-scanning-payment"
  swagger_url  = "https://raw.githubusercontent.com/hmcts/reform-api-docs/master/docs/specs/ccpay-payment-app.bulk-scanning.json"
}

// TODO, look at why this is generating a new template each time
data "template_file" "bulkscanning_policy_template" {
  template = "${file("${path.module}/templates/ccpay-bulkscanning-api-policy.xml")}"

  vars {
    allowed_certificate_thumbprints = "${local.bulkscanning_thumbprints_in_quotes_str}"
    s2s_client_id                   = "${data.azurerm_key_vault_secret.s2s_client_id.value}"
    s2s_client_secret               = "${data.api_gateway_s2s_dummy_secret}"
    s2s_base_url                    = "${data.s2s_base_url}"
  }
}

module "ccpay-bulkscanning-policy" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-api-policy?ref=master"

  api_mgmt_name = "core-api-mgmt-demodata"
  api_mgmt_rg   = "core-infra-demodata-rg"

  api_name               = "${module.ccpay-bulkscanning-api.name}"
  api_policy_xml_content = "${data.template_file.bulkscanning_policy_template.rendered}"
}
