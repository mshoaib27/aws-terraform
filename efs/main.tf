module "efs" {
  source = "terraform-aws-modules/efs/aws"

  name           = "tt-uat-efs"
  creation_token = "tt-uat-token-v2-single-az"
  encrypted      = true
  availability_zone_name = "eu-west-1a"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  lifecycle_policy = {
    transition_to_ia = "AFTER_30_DAYS"
  }
  attach_policy                      = false
  bypass_policy_lockout_safety_check = false
  mount_targets = {
    "eu-west-1a" = {
      subnet_id = var.private_subnets[0]
    }
  }
  security_group_description = "tt-uat-efs security group"
  security_group_vpc_id      = var.vpc_id

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

  tags = merge(
    var.tags,
    {
      Name        = "tt-uat-efs"
      Terraform   = "true"
      Environment = "uat"
    }
  )
}