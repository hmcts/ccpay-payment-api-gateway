# Payment API Gateway Terraform Module
**Note:** Updates to template/api-policy.xml file will not be deployed, because, Terraform will not see them as changes to the TF configurations. In order to deploy, the updated policy on all environments, generate a thumbprint and add it on all the {env}.tfvars file.

## Purpose
Configures the Liberata APIM endpoints for reconciliation and payment processing. This module is used to deploy the API Management service and configure the necessary policies for the payment API gateway.

## Management of Named Values

### S2S Client Secret
This repository adds and manages the s2s client secret as a named value in the API Management service. 

```hcl
resource "azurerm_api_management_named_value" "ccpay_s2s_client_secret" {
  name                = "ccpay-s2s-client-secret"
  api_management_name = var.api_management_name
  resource_group_name = var.resource_group_name
  value               = var.s2s_client_secret
  display_name        = "S2S Client Secret"
  secret              = true
  tags                = ["ccpay", "s2s"]
}
```

The named value is used to authenticate the API Gateway with the S2S service and is referenced from other policies in the API Management service, repositories using this named value include:
- https://github.com/hmcts/ccpay-payment-app
- https://github.com/hmcts/ccpay-bulkscanning-app
- https://github.com/hmcts/ccpay-refunds-app
- https://github.com/hmcts/ccfr-fees-register-app

Service Operational Guide:
https://tools.hmcts.net/confluence/display/DTSFP/CFT+APIM+Service+Operational+Guide

## Recycling values

### How to generate thumbprint:
https://tools.hmcts.net/confluence/display/RP/Test+Api+gateway+with+client+certificate
