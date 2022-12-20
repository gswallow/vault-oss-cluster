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
