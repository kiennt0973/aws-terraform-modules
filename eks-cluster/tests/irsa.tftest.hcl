mock_provider "aws" {
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/mock-role"
    }
  }

  mock_resource "aws_eks_cluster" {
    defaults = {
      identity = [{
        oidc = [{
          issuer = "https://oidc.eks.us-east-1.amazonaws.com/id/TEST"
        }]
      }]
    }
  }
}

variables {
  cluster_name = "test-eks"
  subnet_ids   = ["subnet-00000000000000001", "subnet-00000000000000002"]
}

run "oidc_without_workload_permissions" {
  command = apply

  assert {
    condition = (
      aws_iam_openid_connect_provider.this.url == "https://oidc.eks.us-east-1.amazonaws.com/id/TEST" &&
      aws_iam_openid_connect_provider.this.client_id_list == toset(["sts.amazonaws.com"]) &&
      length(output.irsa_role_arns) == 0
    )
    error_message = "The cluster must register its issuer for STS without creating application roles by default."
  }
}

run "exact_service_account_trust" {
  command = apply

  variables {
    irsa_roles = {
      test-app = {
        namespace            = "apps"
        service_account_name = "app-aws"
        managed_policy_arns  = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
        inline_policies = {
          list_bucket = jsonencode({
            Version = "2012-10-17"
            Statement = [{
              Effect   = "Allow"
              Action   = ["s3:ListBucket"]
              Resource = "arn:aws:s3:::test-app-bucket"
            }]
          })
        }
      }
    }
  }

  assert {
    condition = (
      jsondecode(local.irsa_assume_role_policies["test-app"]).Statement[0].Action == "sts:AssumeRoleWithWebIdentity" &&
      jsondecode(local.irsa_assume_role_policies["test-app"]).Statement[0].Principal.Federated == output.oidc_provider_arn &&
      jsondecode(local.irsa_assume_role_policies["test-app"]).Statement[0].Condition.StringEquals["oidc.eks.us-east-1.amazonaws.com/id/TEST:aud"] == "sts.amazonaws.com" &&
      jsondecode(local.irsa_assume_role_policies["test-app"]).Statement[0].Condition.StringEquals["oidc.eks.us-east-1.amazonaws.com/id/TEST:sub"] == "system:serviceaccount:apps:app-aws" &&
      output.irsa_role_arns["test-app"] == "arn:aws:iam::123456789012:role/mock-role"
    )
    error_message = "IRSA must trust only the configured service account, STS audience, and this cluster's provider."
  }
}

run "reject_wildcard_service_account" {
  command = plan

  variables {
    irsa_roles = {
      test-app = {
        namespace            = "apps"
        service_account_name = "*"
      }
    }
  }

  expect_failures = [var.irsa_roles]
}
