locals {
  cft_api_mgmt_name     = join("-", ["cft-api-mgmt", var.env])
  cft_api_mgmt_rg       = join("-", ["cft", var.env, "network-rg"])
}

module "cft_api_mgmt_product" {
  source        = "git@github.com:hmcts/cnp-module-api-mgmt-product?ref=master"
  name          = var.product_name
  api_mgmt_name = local.cft_api_mgmt_name
  api_mgmt_rg   = local.cft_api_mgmt_rg
}

module "cft_api_mgmt_api" {
  source        = "git@github.com:hmcts/cnp-module-api-mgmt-api?ref=master"
  name          = join("-", [var.product_name, "api"])
  display_name  = "Payments API"
  api_mgmt_name = local.cft_api_mgmt_name
  api_mgmt_rg   = local.cft_api_mgmt_rg
  product_id    = module.cft_api_mgmt_product.product_id
  path          = local.api_base_path
  service_url   = local.payments_api_url
  swagger_url   = "https://raw.githubusercontent.com/hmcts/reform-api-docs/master/docs/specs/ccpay-payment-app.recon-payments-v0.3.json"
  revision      = "1"
}

module "cft_api_mgmt_policy" {
  source                 = "git@github.com:hmcts/cnp-module-api-mgmt-api-policy?ref=master"
  api_mgmt_name          = local.cft_api_mgmt_name
  api_mgmt_rg            = local.cft_api_mgmt_rg
  api_name               = module.cft_api_mgmt_api.name
  api_policy_xml_content = data.template_file.policy_template.rendered
}
