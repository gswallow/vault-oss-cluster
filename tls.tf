resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits = "4096"
}
resource "tls_private_key" "ca" {
  algorithm   = "RSA"
  rsa_bits    = 4096
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem       = tls_private_key.ca.private_key_pem
  is_ca_certificate     = true
  validity_period_hours = 26280 # 3 years
  allowed_uses          = [ "cert_signing", "key_encipherment", "digital_signature" ]

  subject {
    common_name  = "vault-ca.${var.tls_cert_domain}"
    organization = local.tls_cert_org
  }
}
