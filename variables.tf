variable "aws_region" {
  type        = string
  description = "The AWS region in which to create resources"
  default     = "us-east-1"
}

variable "replica_region" {
  type        = string
  description = "The AWS region in which to create resources"
  default     = "us-west-2"
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
  type        = list(string)
  description = "A list of CIDR blocks to allow SSH access"
  default     = ["0.0.0.0/0"]
}

variable "security_group_allow_http_8200_cidr" {
  type        = list(string)
  description = "A list of CIDR blocks to allow direct Vault access"
  default     = ["0.0.0.0/0"]
}

variable "vault_cluster_id" {
  type        = string
  description = "The cluster ID to use to auto-join nodes"
  default     = "cluster3"
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

variable "vault_master_node_id" {
  type        = string
  description = "The 'master' node ID (first node of the cluster)"
  default     = "node0"
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

variable "vault_subnet_tag" {
  type        = map(string)
  description = "An optional tag to identify subnets for vault nodes (e.g. VPC:tier = private vs public)"
  default     = {}
}

variable "vault_third_party_account_roles" {
  type        = list(string)
  description = "A list of ARNs of third party account roles that vault can assume on behalf of customers"
  default     = []
}

variable "nlb_create" {
  type        = bool
  description = "Create a network load balancer?"
  default     = true
}

variable "nlb_faces_public" {
  type        = bool
  description = "Create a public facing load balancer?"
  default     = true
}

variable "nlb_subnet_tag" {
  type        = map(string)
  description = "An optional tag to identify subnets for NLBs (e.g. VPC:tier = private vs public)"
  default     = {}
}

variable "route53_create_record" {
  type        = bool
  description = "Create a route 53 record that points to an NLB?"
  default     = true
}

variable "route53_use_public_zone" {
  type        = bool
  description = "Use a public Route 53 zone?"
  default     = true
}

variable "cert_validation_method" {
  type        = string
  description = "The way we will validate cert requests.  May be 'DNS' or 'EMAIL'"
  default     = "DNS"
}

variable "monitor_vault_processes" {
  type        = bool
  description = "Set up AWS Cloudwatch alarms that trigger when a vault process is not running"
  default     = true
}

variable "monitor_vault_disk_usage" {
  type        = bool
  description = "Set up AWS Cloudwatch alarms that trigger when a filesystem is getting full"
  default     = true
}

locals {
  prefix                 = replace(lower("${var.org}-${var.env}-${var.project}"), "_", "-")
  tls_cert_org           = var.tls_cert_org == null ? var.org : var.tls_cert_org
  vault_cluster_fqdn     = var.vault_cluster_fqdn == null ? "vault-${var.vault_cluster_id}.${var.env}.${var.tls_cert_domain}" : var.vault_cluster_fqdn
  nlb_subnet_tag         = var.nlb_subnet_tag == {} ? var.vault_subnet_tag : var.nlb_subnet_tag
  cert_validation_method = var.route53_use_public_zone ? var.cert_validation_method : "EMAIL"
  tags = merge({
    "Organization:environment" = var.env,
    "Organization:name"        = var.org,
    "Organization:project"     = var.project,
    "vault:cluster-id"         = var.vault_cluster_id
  }, var.tags)
}
