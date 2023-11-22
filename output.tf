output "ssh_private_key" {
  sensitive = true
  value     = tls_private_key.ssh.private_key_openssh
}

output "ca_cert_pem" {
  value = tls_self_signed_cert.ca.cert_pem
}

output "vault_url" {
  value = "https://${aws_route53_record.vault.0.fqdn}:8200"
}

output "unseal_key_arn_prefix" {
  value = join(":",
    [
      "arn",
      data.aws_partition.current.partition,
      "secretsmanager",
      var.aws_region,
      data.aws_caller_identity.current.account_id,
      "secret",
      "/vault/init/${local.vault_cluster_fqdn}"
    ]
  )
}
