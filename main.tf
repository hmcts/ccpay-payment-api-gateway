locals {
  # list of the thumbprints of the SSL certificates that should be accepted by the API (gateway)
  allowed_certificate_thumbprints = [
    # API tests
    "${var.api_gateway_test_certificate_thumbprint}",
    "5F78A689275613355ADEE0230D2310F6239849E3"
  ]

  thumbprints_in_quotes = "${formatlist("&quot;%s&quot;", local.allowed_certificate_thumbprints)}"
  thumbprints_in_quotes_str = "${join(",", local.thumbprints_in_quotes)}"
  api_policy = "${replace(file("template/api-policy.xml"), "ALLOWED_CERTIFICATE_THUMBPRINTS", local.thumbprints_in_quotes_str)}"
}
data "template_file" "api_template" {
  template = "${file("${path.module}/template/api.json")}"
}

resource "azurerm_template_deployment" "api" {
  template_body       = "${data.template_file.api_template.rendered}"
  name                = "${var.product}-api-${var.env}"
  deployment_mode     = "Incremental"
  resource_group_name = "core-infra-${var.env}"
  count               = "${var.env != "preview" ? 1: 0}"

  parameters = {
    apiManagementServiceName  = "core-api-mgmt-${var.env}"
    apiName                   = "${var.product}-api"
    apiProductName            = "${var.product}"
    serviceUrl                = "http://payment-api-${var.env}.service.core-compute-${var.env}.internal"
    apiBasePath               = "payments-api"
    policy                    = "${local.api_policy}"
  }
}
