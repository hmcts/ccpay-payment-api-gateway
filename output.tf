output "vaultName" {
  value = "${module.payment-vault.key_vault_name}"
}

output "vaultUri" {
  value = "${module.payment-vault.key_vault_uri}"
}