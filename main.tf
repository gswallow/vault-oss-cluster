resource "aws_kms_key" "vault" {
  description             = "Hashicorp Vault Cluster ${var.vault_cluster_id} Auto-Unseal"
  deletion_window_in_days = 7
  tags                    = merge(local.tags, { Name = "${local.prefix}-${var.vault_cluster_id}-auto-unseal" })
}

resource "aws_key_pair" "vault" {
  key_name   = "${local.prefix}-${var.vault_cluster_id}-ssh"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "aws_security_group" "vault" {
  name        = "${local.prefix}-${var.vault_cluster_id}-sg"
  description = "Allow inbound SSH and Vault ports"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.security_group_allow_ssh_cidr
  }

  ingress {
    description = "Allow Vault HTTPS"
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = var.security_group_allow_https_8200_cidr
  }

  ingress {
    description = "Allow Vault messages"
    from_port   = 8201
    to_port     = 8201
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "Allow outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_instance_profile" "vault" {
  name = "${local.prefix}-${var.vault_cluster_id}-instance-profile"
  role = aws_iam_role.vault.name
}

resource "aws_iam_role" "vault" {
  name = "${local.prefix}-${var.vault_cluster_id}-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = local.tags
}

resource "aws_iam_role_policy" "vault_auto_unseal" {
  name = "${local.prefix}-${var.vault_cluster_id}-auto-unseal-kms"
  role = aws_iam_role.vault.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["kms:Decrypt", "kms:Encrypt", "kms:DescribeKey"]
        Effect   = "Allow"
        Resource = [aws_kms_key.vault.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy" "store_vault_unseal_keys" {
  name = "${local.prefix}-${var.vault_cluster_id}-store-unseal-keys"
  role = aws_iam_role.vault.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
          "secretsmanager:CreateSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:ReplicateSecretToRegions"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:${data.aws_partition.current.partition}:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:/vault/init/*",
          "arn:${data.aws_partition.current.partition}:secretsmanager:${var.replica_region}:${data.aws_caller_identity.current.account_id}:secret:/vault/init/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "vault_describe_instances" {
  name = "${local.prefix}-${var.vault_cluster_id}-describe-instances"
  role = aws_iam_role.vault.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["ec2:DescribeInstances"]
        Effect   = "Allow"
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy" "vault_create_iam_users" {
  name = "${local.prefix}-${var.vault_cluster_id}-create-iam-users"
  role = aws_iam_role.vault.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "iam:AttachUserPolicy",
          "iam:CreateAccessKey",
          "iam:CreateUser",
          "iam:DeleteAccessKey",
          "iam:DeleteUser",
          "iam:DeleteUserPolicy",
          "iam:DetachUserPolicy",
          "iam:GetUser",
          "iam:ListAccessKeys",
          "iam:ListAttachedUserPolicies",
          "iam:ListGroupsForUser",
          "iam:ListUserPolicies",
          "iam:PutUserPolicy",
          "iam:AddUserToGroup",
          "iam:RemoveUserFromGroup"
        ]
        Effect   = "Allow"
        Resource = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/vault-*"]
      }
    ]
  })
}

resource "aws_launch_template" "vault" {
  count                  = var.vault_cluster_node_count
  name                   = "Hashicorp_Vault_Cluster_${var.vault_cluster_id}-Node-${count.index}-lt"
  ebs_optimized          = true
  image_id               = data.aws_ssm_parameter.amazon_linux_ami.value
  instance_type          = var.vault_cluster_instance_type
  key_name               = aws_key_pair.vault.key_name
  vpc_security_group_ids = [aws_security_group.vault.id]
  update_default_version = true
  user_data = base64encode(templatefile("${path.cwd}/templates/user-data.tpl",
    {
      ca_crt                       = base64encode(tls_self_signed_cert.ca.cert_pem),
      ca_key                       = base64encode(tls_private_key.ca.private_key_pem),
      vault_cluster_fqdn           = local.vault_cluster_fqdn,
      tls_cert_country_name        = var.tls_cert_country_name,
      tls_cert_state_province_name = var.tls_cert_state_province_name,
      tls_cert_locality_name       = var.tls_cert_locality_name,
      replica_region               = var.replica_region
  }))

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = data.aws_kms_key.ebs.arn
      volume_type           = "gp2"
      volume_size           = var.vault_root_volume_size
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.vault.name
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    instance_metadata_tags      = "enabled"
    http_put_response_hop_limit = 2
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(local.tags, { "vault:node-id" = "node${count.index}" })
  }

  tag_specifications {
    resource_type = "network-interface"
    tags          = merge(local.tags, { "vault:node-id" = "node${count.index}" })
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.tags, {
      "vault:node-id"        = "node${count.index}",
      "vault:kms-key-id"     = aws_kms_key.vault.arn,
      "vault:cluster-fqdn"   = local.vault_cluster_fqdn,
      "vault:master-node-id" = var.vault_master_node_id,
      Name                   = "${local.prefix}-vault-${var.vault_cluster_id}-node${count.index}"
    })
  }
}

resource "aws_autoscaling_group" "vault_node" {
  count                     = var.vault_cluster_node_count
  name                      = "${local.prefix}-${var.vault_cluster_id}-node${count.index}"
  max_size                  = 1
  min_size                  = 0
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = [data.aws_subnets.vault.ids[count.index]]
  target_group_arns         = var.nlb_create ? aws_lb_target_group.vault.*.arn : null

  launch_template {
    id      = aws_launch_template.vault[count.index].id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(local.tags, { Name = "${local.prefix}-vault-${var.vault_cluster_id}-auto-unseal" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false
    }
  }
}

resource "aws_lb" "vault" {
  count                            = var.nlb_create ? 1 : 0
  name                             = "${var.env}-${var.vault_cluster_id}-nlb"
  internal                         = var.nlb_faces_public ? false : true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  ip_address_type                  = "ipv4"
  subnets                          = data.aws_subnets.nlb.ids

  tags = local.tags
}

resource "aws_lb_target_group" "vault" {
  count    = var.nlb_create ? 1 : 0
  name     = "vault-${var.env}-${var.vault_cluster_id}-tg"
  port     = 8200
  protocol = "TCP"
  vpc_id   = data.aws_vpc.selected.id
}

resource "aws_lb_listener" "vault" {
  count             = var.nlb_create ? 1 : 0
  load_balancer_arn = aws_lb.vault.0.arn
  port              = 8200
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault.0.arn
  }
}

resource "aws_route53_record" "vault" {
  count   = var.route53_create_record ? var.nlb_create ? 1 : 0 : 0
  zone_id = data.aws_route53_zone.selected.0.id
  name    = "${local.vault_cluster_fqdn}."
  type    = "A"

  alias {
    name                   = aws_lb.vault.0.dns_name
    zone_id                = aws_lb.vault.0.zone_id
    evaluate_target_health = false
  }
}


