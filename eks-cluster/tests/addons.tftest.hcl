mock_provider "aws" {
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/test-efs-csi"
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

run "no_addons_by_default" {
  command = plan

  assert {
    condition = (
      length(aws_eks_addon.before_compute) == 0 &&
      length(aws_eks_addon.after_compute) == 0
    )
    error_message = "Existing callers must not gain managed add-ons unless configured."
  }
}

run "managed_addons_with_dedicated_csi_role" {
  command = apply

  variables {
    addons = {
      vpc-cni    = {}
      coredns    = {}
      kube-proxy = {}
      aws-efs-csi-driver = {
        addon_version             = "v2.1.13-eksbuild.1"
        service_account_role_name = "test-efs-csi"
      }
    }
    irsa_roles = {
      test-efs-csi = {
        namespace            = "kube-system"
        service_account_name = "efs-csi-controller-sa"
        managed_policy_arns  = ["arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"]
      }
    }
  }

  assert {
    condition = (
      keys(aws_eks_addon.before_compute) == ["vpc-cni"] &&
      keys(aws_eks_addon.after_compute) == ["aws-efs-csi-driver", "coredns", "kube-proxy"] &&
      aws_eks_addon.after_compute["aws-efs-csi-driver"].service_account_role_arn == output.irsa_role_arns["test-efs-csi"] &&
      output.addon_versions["aws-efs-csi-driver"] == "v2.1.13-eksbuild.1" &&
      aws_eks_addon.before_compute["vpc-cni"].resolve_conflicts_on_create == "OVERWRITE" &&
      aws_eks_addon.after_compute["coredns"].resolve_conflicts_on_update == "PRESERVE"
    )
    error_message = "CNI must be installed before compute, other add-ons after compute, with CSI's dedicated role and version preserved."
  }

  assert {
    condition = (
      jsondecode(local.irsa_assume_role_policies["test-efs-csi"]).Statement[0].Condition.StringEquals["oidc.eks.us-east-1.amazonaws.com/id/TEST:sub"] == "system:serviceaccount:kube-system:efs-csi-controller-sa" &&
      jsondecode(local.irsa_assume_role_policies["test-efs-csi"]).Statement[0].Condition.StringEquals["oidc.eks.us-east-1.amazonaws.com/id/TEST:aud"] == "sts.amazonaws.com"
    )
    error_message = "The CSI controller role must trust only its exact service account and STS audience."
  }
}

run "only_defined_addons" {
  command = plan

  variables {
    addons = {
      coredns    = {}
      kube-proxy = {}
    }
  }

  assert {
    condition = (
      length(aws_eks_addon.before_compute) == 0 &&
      keys(aws_eks_addon.after_compute) == ["coredns", "kube-proxy"] &&
      keys(output.addon_versions) == ["coredns", "kube-proxy"]
    )
    error_message = "Only the add-ons defined in the map must be managed and reported."
  }
}

run "remove_all_addons" {
  command = plan

  variables {
    addons = {}
  }

  assert {
    condition = (
      length(aws_eks_addon.before_compute) == 0 &&
      length(aws_eks_addon.after_compute) == 0 &&
      length(output.addon_versions) == 0
    )
    error_message = "An empty map must remove all managed add-ons and version outputs."
  }
}
