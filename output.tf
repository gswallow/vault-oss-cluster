output "ssh_private_key" {
  sensitive = true
  value     = tls_private_key.ssh.private_key_openssh
}
