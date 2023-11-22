resource "vault_mount" "pki_aws" {
  path                  = "pki-aws"
  type                  = "pki"
  description           = "PKI store for AWS IAM Roles Anywhere"
  max_lease_ttl_seconds = 8760 * 60 * 60
}

resource "vault_pki_secret_backend_root_cert" "pki_aws_root" {
  backend              = vault_mount.pki_aws.path
  type                 = "internal"
  common_name          = var.root_cert_common_name
  ttl                  = 8760 * 60 * 60
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
}

resource "vault_pki_secret_backend_role" "pki_aws" {
  backend            = vault_mount.pki_aws.path
  name               = "pki_aws_role"
  ttl                = 3600
  allow_ip_sans      = false
  key_type           = "rsa"
  key_bits           = 4096
  allowed_domains    = var.allowed_domains
  allow_bare_domains = false
  allow_subdomains   = true
  allow_glob_domains = true
}

resource "vault_pki_secret_backend_cert" "client" {
  depends_on  = [vault_pki_secret_backend_role.pki_aws]
  backend     = vault_mount.pki_aws.path
  name        = vault_pki_secret_backend_role.pki_aws.name
  common_name = var.cert_common_name
}
