# ccpay-payment-api-gateway 
**Note:** Updates to template/api-policy.xml file will not be deployed, because, Terraform will not see them as changes to the TF configurations. In order to deploy, the updated policy on all environments, generate a thumbprint and add it on all the {env}.tfvars file.

### How to generate thumbprint:
https://tools.hmcts.net/confluence/display/RP/Test+Api+gateway+with+client+certificate