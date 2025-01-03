module "efs" {
  source = "terraform-aws-modules/efs/aws"

  name           = "test"
  creation_token = "test-token"
  encrypted      = true
  kms_key_arn    = module.kms.kms_key_arn

  # performance_mode                = "maxIO"
  # NB! PROVISIONED TROUGHPUT MODE WITH 256 MIBPS IS EXPENSIVE ~$1500/month
  # throughput_mode                 = "provisioned"
  # provisioned_throughput_in_mibps = 256

  lifecycle_policy = {
    transition_to_ia = "AFTER_30_DAYS"
  }

  # File system policy
  attach_policy                      = true
  bypass_policy_lockout_safety_check = false
  policy_statements = [
    {
      sid     = "Example"
      actions = ["elasticfilesystem:ClientMount"]
      principals = [
        {
          type        = "AWS"
          identifiers = []
        }
      ]
    }
  ]

  # Mount targets / security group
  mount_targets = {
    "sa-east-1a" = {
      subnet_id = var.private_subnets[0]
    }
    "sa-east-1b" = {
      subnet_id = var.private_subnets[1]
    }
    "sa-east-1c" = {
      subnet_id = var.private_subnets[2]
    }
  }
  security_group_description = "Example EFS security group"
  security_group_vpc_id      = var.vpc_id
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = var.vpc_cidr
    }
  }

  # Access point(s)
  access_points = {
    posix_example = {
      name = "posix-example"
      posix_user = {
        gid            = 1001
        uid            = 1001
        secondary_gids = [1002]
      }

      tags = {
        Additionl = "yes"
      }
    }
    root_example = {
      root_directory = {
        path = "/example"
        creation_info = {
          owner_gid   = 1001
          owner_uid   = 1001
          permissions = "755"
        }
      }
    }
  }

  # Backup policy
  enable_backup_policy = false

  # Replication configuration
  create_replication_configuration = false
  replication_configuration_destination = {
    region = var.region
  }

  tags = {
    Name = "shoaib"
    Terraform   = "true"
    Environment = "dev"
  }
}