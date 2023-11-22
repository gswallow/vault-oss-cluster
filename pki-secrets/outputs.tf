output "client_cert_pem" {
  value = vault_pki_secret_backend_cert.client.certificate
}

output "client_key_pem" {
  value     = vault_pki_secret_backend_cert.client.private_key
  sensitive = true
}
