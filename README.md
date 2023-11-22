# Janky Vault Cluster

This terraform project creates a vault cluster with internal storage using Raft.
By default it will spin up the cluster in your default VPC, which saves costs.
Pretty much any other choice (e.g. spinning it up in private subnets, or your
own VPC) is untested.

Optionally, you can create a network load balancer and point a route 53 record at
it using the Route 53 zone of your choice.  

Root tokens will be stored in AWS Secrets Manager, in a primary and secondary AWS
region, under the "/vault/init/cluster-name" secret parameter. CLI commands can
be run by setting the `VAULT_TOKEN` environment variable on one of the nodes. The
`VAULT_CAPATH` environment variable should be set for you (per 
`/etc/profile.d/vault.sh`).  For security reasons, the vault instances have the
ability to create and update parameters in AWS Secrets Manager, but not to 
retrieve the values.

The chief reason this project exists is to toy with the auto-unseal feature and
the AWS secrets engine.  Everything is in "experimental" stage right now and you
may use this project at your own peril.

## CA Certs
Mac users: you can import the CA cert to your system keychain using Keychain
Access.  This will allow you to trust the CA cert, and actually visit the vault
cluster you've stood up.

---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.8.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 3.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.8.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.vault_node](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_metric_alarm.disks](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.vault_process](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_instance_profile.vault](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.vault](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.assume_third_party_account_role_policy](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.cloudwatch_config_parameter_store](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.store_vault_unseal_keys](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.vault_auto_unseal](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.vault_create_iam_users](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.vault_describe_instances](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_key_pair.vault](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/key_pair) | resource |
| [aws_kms_key.vault](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/kms_key) | resource |
| [aws_launch_template.vault](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/launch_template) | resource |
| [aws_lb.vault](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/lb) | resource |
| [aws_lb_listener.vault](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.vault](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/lb_target_group) | resource |
| [aws_route53_record.vault](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/route53_record) | resource |
| [aws_security_group.vault](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/security_group) | resource |
| [aws_ssm_parameter.cloudwatch_config](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/ssm_parameter) | resource |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/3.2.0/docs/resources/private_key) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/3.2.0/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/3.2.0/docs/resources/self_signed_cert) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/data-sources/caller_identity) | data source |
| [aws_kms_key.ebs](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/data-sources/kms_key) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/data-sources/partition) | data source |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/data-sources/route53_zone) | data source |
| [aws_ssm_parameter.amazon_linux_ami](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/data-sources/ssm_parameter) | data source |
| [aws_subnets.nlb](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/data-sources/subnets) | data source |
| [aws_subnets.vault](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/data-sources/subnets) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region in which to create resources | `string` | `"us-east-1"` | no |
| <a name="input_env"></a> [env](#input\_env) | The name of the environment, for use in AWS resource tags | `string` | `"dev"` | no |
| <a name="input_monitor_vault_disk_usage"></a> [monitor\_vault\_disk\_usage](#input\_monitor\_vault\_disk\_usage) | Set up AWS Cloudwatch alarms that trigger when a filesystem is getting full | `bool` | `true` | no |
| <a name="input_monitor_vault_processes"></a> [monitor\_vault\_processes](#input\_monitor\_vault\_processes) | Set up AWS Cloudwatch alarms that trigger when a vault process is not running | `bool` | `true` | no |
| <a name="input_nlb_create"></a> [nlb\_create](#input\_nlb\_create) | Create a network load balancer? | `bool` | `true` | no |
| <a name="input_nlb_faces_public"></a> [nlb\_faces\_public](#input\_nlb\_faces\_public) | Create a public facing load balancer? | `bool` | `true` | no |
| <a name="input_nlb_subnet_tag"></a> [nlb\_subnet\_tag](#input\_nlb\_subnet\_tag) | An optional tag to identify subnets for NLBs (e.g. VPC:tier = private vs public) | `map(string)` | `{}` | no |
| <a name="input_org"></a> [org](#input\_org) | The name of the organization hosting the AWS resources, for use in resource tags | `string` | `"GregOnAWS"` | no |
| <a name="input_project"></a> [project](#input\_project) | The name of the project served by these AWS resources, for use in resource tags | `string` | `"vaultdemo"` | no |
| <a name="input_replica_region"></a> [replica\_region](#input\_replica\_region) | The AWS region in which to create resources | `string` | `"us-west-2"` | no |
| <a name="input_route53_create_record"></a> [route53\_create\_record](#input\_route53\_create\_record) | Create a route 53 record that points to an NLB? | `bool` | `true` | no |
| <a name="input_route53_use_public_zone"></a> [route53\_use\_public\_zone](#input\_route53\_use\_public\_zone) | Use a public Route 53 zone? | `bool` | `true` | no |
| <a name="input_security_group_allow_https_8200_cidr"></a> [security\_group\_allow\_https\_8200\_cidr](#input\_security\_group\_allow\_https\_8200\_cidr) | A list of CIDR blocks to allow SSH access | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_security_group_allow_ssh_cidr"></a> [security\_group\_allow\_ssh\_cidr](#input\_security\_group\_allow\_ssh\_cidr) | A list of CIDR blocks to allow SSH access | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A key/value map of additional resource tags to apply to AWS resources | `map(string)` | `{}` | no |
| <a name="input_tls_cert_country_name"></a> [tls\_cert\_country\_name](#input\_tls\_cert\_country\_name) | The ISO-3166 country code of all SSL certs | `string` | `"US"` | no |
| <a name="input_tls_cert_domain"></a> [tls\_cert\_domain](#input\_tls\_cert\_domain) | The domain name to use for certificate subject names | `string` | `"gregonaws.net"` | no |
| <a name="input_tls_cert_locality_name"></a> [tls\_cert\_locality\_name](#input\_tls\_cert\_locality\_name) | The locality (city) name to use for all SSL certs | `string` | `"Indianapolis"` | no |
| <a name="input_tls_cert_org"></a> [tls\_cert\_org](#input\_tls\_cert\_org) | The organization name to use for certificate subject names | `string` | `null` | no |
| <a name="input_tls_cert_state_province_name"></a> [tls\_cert\_state\_province\_name](#input\_tls\_cert\_state\_province\_name) | The state or province to use for all SSL certs | `string` | `"Indiana"` | no |
| <a name="input_vault_cluster_fqdn"></a> [vault\_cluster\_fqdn](#input\_vault\_cluster\_fqdn) | The fully qualified domain name of the vault cluster | `string` | `null` | no |
| <a name="input_vault_cluster_id"></a> [vault\_cluster\_id](#input\_vault\_cluster\_id) | The cluster ID to use to auto-join nodes | `string` | `"cluster3"` | no |
| <a name="input_vault_cluster_instance_type"></a> [vault\_cluster\_instance\_type](#input\_vault\_cluster\_instance\_type) | The instance type to launch | `string` | `"t3.micro"` | no |
| <a name="input_vault_cluster_node_count"></a> [vault\_cluster\_node\_count](#input\_vault\_cluster\_node\_count) | The number of nodes to create | `number` | `3` | no |
| <a name="input_vault_master_node_id"></a> [vault\_master\_node\_id](#input\_vault\_master\_node\_id) | The 'master' node ID (first node of the cluster) | `string` | `"node0"` | no |
| <a name="input_vault_root_volume_size"></a> [vault\_root\_volume\_size](#input\_vault\_root\_volume\_size) | The amount of disk space to allocate for each vault node's root volume | `number` | `20` | no |
| <a name="input_vault_subnet_tag"></a> [vault\_subnet\_tag](#input\_vault\_subnet\_tag) | An optional tag to identify subnets for vault nodes (e.g. VPC:tier = private vs public) | `map(string)` | `{}` | no |
| <a name="input_vault_third_party_account_roles"></a> [vault\_third\_party\_account\_roles](#input\_vault\_third\_party\_account\_roles) | A list of ARNs of third party account roles that vault can assume on behalf of customers | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | An optional ID of a VPC in which to launch vault | `string` | `null` | no |
| <a name="input_vpc_use_default"></a> [vpc\_use\_default](#input\_vpc\_use\_default) | Use the default VPC | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ca_cert_pem"></a> [ca\_cert\_pem](#output\_ca\_cert\_pem) | n/a |
| <a name="output_ssh_private_key"></a> [ssh\_private\_key](#output\_ssh\_private\_key) | n/a |
| <a name="output_unseal_key_arn_prefix"></a> [unseal\_key\_arn\_prefix](#output\_unseal\_key\_arn\_prefix) | n/a |
| <a name="output_vault_url"></a> [vault\_url](#output\_vault\_url) | n/a |
