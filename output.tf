output "ssh_private_key" {
  sensitive = true
  value     = tls_private_key.ssh.private_key_openssh
}

output "ca_cert_pem" {
  value     = tls_self_signed_cert.ca.cert_pem
}
