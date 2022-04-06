variable "aws_region" {
  type        = string
  description = "The AWS region in which to create resources"
  default     = "us-east-1"
}

variable "env" {
  type        = string
  description = "The name of the environment, for use in AWS resource tags"
  default     = "dev"
}

variable "org" {
  type        = string
  description = "The name of the organization hosting the AWS resources, for use in resource tags"
  default     = "GregOnAWS"
}

variable "project" {
  type        = string
  description = "The name of the project served by these AWS resources, for use in resource tags"
  default     = "vaultdemo"
}

variable "tags" {
  type        = map(string)
  description = "A key/value map of additional resource tags to apply to AWS resources"
  default     = {}
}

variable "security_group_allow_ssh_cidr" {
  type = list(string)
  description = "A list of CIDR blocks to allow SSH access"
  default = [ "0.0.0.0/0" ]
}

variable "security_group_allow_https_8200_cidr" {
  type = list(string)
  description = "A list of CIDR blocks to allow SSH access"
  default = [ "0.0.0.0/0" ]
}

variable "vault_cluster_id" {
  type        = string
  description = "The cluster ID to use to auto-join nodes"
  default     = "cluster1"
}

variable "vault_cluster_fqdn" {
  type        = string
  description = "The fully qualified domain name of the vault cluster"
  default     = null
}

variable "vault_cluster_node_count" {
  type        = number
  description = "The number of nodes to create"
  default     = 3
}

variable "vault_cluster_instance_type" {
  type        = string
  description = "The instance type to launch"
  default     = "t3.micro"
}

variable "vault_root_volume_size" {
  type        = number
  description = "The amount of disk space to allocate for each vault node's root volume"
  default     = 20
}

variable "tls_cert_domain" {
  type        = string
  description = "The domain name to use for certificate subject names"
  default     = "gregonaws.net"
}

variable "tls_cert_org" {
  type        = string
  description = "The organization name to use for certificate subject names"
  default     = null
}

variable "tls_cert_country_name" {
  type        = string
  description = "The ISO-3166 country code of all SSL certs"
  default     = "US"
}

variable "tls_cert_state_province_name" {
  type        = string
  description = "The state or province to use for all SSL certs"
  default     = "Indiana"
}

variable "tls_cert_locality_name" {
  type        = string
  description = "The locality (city) name to use for all SSL certs"
  default     = "Indianapolis"
}

variable "vpc_use_default" {
  type        = bool
  description = "Use the default VPC"
  default     = true
}
  
variable "vpc_id" {
  type        = string
  description = "An optional ID of a VPC in which to launch vault"
  default     = null
}

variable "vpc_subnet_tag" {
  type        = map(string)
  description = "An optional tag to identify subnets (e.g. VPC:tier = private vs public)"
  default     = {}
}
  
locals {
  prefix             = replace(lower("${var.org}-${var.env}-${var.project}"), "_", "-")
  tls_cert_org       = var.tls_cert_org == null ? var.org : var.tls_cert_org
  vault_cluster_fqdn = var.vault_cluster_fqdn == null ? "vault-${var.env}-${var.vault_cluster_id}.${var.tls_cert_domain}" : var.vault_cluster_fqdn
  tags = merge({
    "Organization:environment" = var.env,
    "Organization:name"        = var.org,
    "Organization:project"     = var.project,
    "vault:cluster-id"         = var.vault_cluster_id
  }, var.tags)
}
