# AWS Terraform Modules

Reusable Terraform modules for cloning company infrastructure.

## State ownership

Modules do not configure a backend. Configure one once in each root deployment so
all modules share the deployment's remote state and locking policy. For example:

```hcl
terraform {
	backend "s3" {
		bucket       = "company-terraform-state"
		key          = "environments/production/terraform.tfstate"
		region       = "ap-southeast-1"
		encrypt      = true
		use_lockfile = true
	}
}
```

Modules declare provider sources without Terraform or provider version
constraints. Provider declarations are kept in `providers.tf`. Keep the root
deployment's dependency lock file to reuse reviewed provider selections;
unlocked initialization can select newer providers with breaking changes.

## ECS deployment stages

Use `ecs-cluster` to manage an ECS cluster independently. Pass its `cluster_id`
to `ecs-service`, which manages the Fargate task definition and ECS service
together. Render the container definitions template in Terragrunt and pass the
result as `container_definitions`; the module consumes that JSON directly.
Both modules accept optional `tags`.

`ecs-service` accepts an optional `efs_volume` object with `name`,
`file_system_id`, and `access_point_id`. It creates a task volume with root `/`,
TLS encryption, and IAM authorization. Reference its name in the container
JSON's `mountPoints` (for example, a read/write mount at `/data`). The caller
must allow NFS TCP 2049 from task SGs to EFS mount targets and grant the task
role `elasticfilesystem:ClientMount` and, for writable mounts,
`elasticfilesystem:ClientWrite` on the file system. Omitting `efs_volume`
preserves task definitions without EFS.

Use `eks-cluster` to create an EKS control plane and one managed node group
together. It creates the control-plane and node IAM roles, places the cluster
and nodes in the supplied subnets, and defaults to private-only API access.
The default node group is one on-demand `t3.medium` instance, scalable to two;
the public endpoint is disabled and control-plane logging is opt-in. The cluster
creator receives Kubernetes administrator access. Operators must connect to
the VPC to reach the private Kubernetes API endpoint.

### EKS managed add-ons

Set `addons` to a map keyed by EKS add-on name. Each value accepts an optional
`addon_version` and `service_account_role_name` referencing a key in
`irsa_roles`. The default empty map preserves existing callers. The live
configuration enables `vpc-cni`, `coredns`, `kube-proxy`, and
`aws-efs-csi-driver`. VPC CNI is installed before managed nodes; the remaining
add-ons wait for nodes so their pods can become healthy. Existing node CNI
permissions are retained.

Every entry defined in `addons` is created; no enable flag is required.
Remove an entry to plan deletion of that managed add-on. This uninstalls the
add-on; it does not merely pause updates. Existing resource addresses remain
unchanged. Roles in `irsa_roles` remain independently managed.
Do not remove VPC CNI, CoreDNS or kube-proxy without a working replacement;
doing so can break node readiness, DNS or service networking. Removing EFS CSI
can disrupt volume provisioning and mounts.

Omit `addon_version` to use EKS's default compatible version on creation, or
pin a reviewed version for the selected Kubernetes release. This is not an
automatic latest-version upgrade mechanism. `addon_versions` reports installed
versions. Creation uses `OVERWRITE` to adopt default self-managed components;
updates use `PRESERVE` to retain custom settings. Review existing self-managed
installations and import already-managed add-ons before applying rather than
trying to create duplicates. The EFS CSI controller role is separate from
application roles and uses `AmazonEFSCSIDriverPolicy` for tagged access-point
provisioning. Installing the driver does not create StorageClasses, PVs or PVCs
or pass application IRSA credentials to node mounts.

### EKS pod AWS permissions (IRSA)

The EKS module registers the cluster's OIDC issuer with IAM, with
`sts.amazonaws.com` as its audience. IAM retrieves the provider certificate
thumbprint; no Terraform TLS lookup or hard-coded thumbprint is needed.
`oidc_provider_arn` and `oidc_issuer_url` are available for external trust
policies. Existing cluster and node-group resource addresses are unchanged.

Set `irsa_roles` to create dedicated pod roles through the shared `iam-role`
module. Keys are complete IAM role names (unique in the account). Each role
trusts exactly one namespace/service-account subject and the STS audience
using `StringEquals`. Supply `managed_policy_arns`, `inline_policies` (policy
name to JSON), or both. The default empty map grants no new workload
permissions; a role without permission policies cannot access AWS resources.
See the service README for a complete input and service-account example.

The module does not create application service accounts or deployments;
EKS manages service accounts belonging to configured managed add-ons.
Annotate the account with the ARN from `irsa_role_arns` and configure the pod's
`serviceAccountName`. Use an IRSA-capable AWS SDK's default credential chain,
without static AWS credentials. Pods need network access to STS and the target
AWS services through NAT or appropriate VPC endpoints. Restrict pod access to
EC2 instance metadata separately to prevent fallback to node-role credentials;
IRSA alone does not isolate those credentials. Existing node policies,
including the VPC CNI policy, are unchanged.

Mocked regression tests are in `eks-cluster/tests/irsa.tftest.hcl` and require
Terraform 1.7 or newer. After initializing the module, run
`terraform test` from its directory.

`alb` owns the load balancer and listeners, not application target groups.
Its `listener_arn` output selects HTTPS when configured, otherwise HTTP.
Use `alb-target-group` for HTTP IP targets and `alb-listener-rule` to forward
matching paths to a target group. The ECS service composition creates those
resources in its own state and waits for the rule before creating the ECS
service; ECS itself registers task IPs.
The `alb-listener-rule` priority is optional: omit it or pass null for the AWS
provider to assign the next available priority after the current highest rule.
Existing rules retain their assigned priority when omitted. Set an integer
from 1 to 50000 to control evaluation order (lower numbers run first).
Automatic assignment does not prioritize specific paths over catch-all paths.

## REST API Gateway

`api-gateway` creates a regional API Gateway REST API backed by a Lambda
function. Supply both `lambda_invoke_arn` (the Lambda API Gateway invocation
URI) and `lambda_function_name`; the module creates proxy routes for `/` and
`/{proxy+}`, grants API Gateway permission to invoke the function, and deploys
the API to `stage_name` (default `prod`). The API is unauthenticated, so add an
authorizer and route-level authorization if the endpoints must be protected.
This module no longer configures an ALB integration; REST APIs cannot use the
HTTP API VPC Link setup previously used here. The mocked
`api-gateway/tests/lambda.tftest.hcl` covers the Lambda proxy configuration
(Terraform 1.7 or newer). Converting an existing HTTP API replaces it with a
new REST API, so review the plan for destruction/recreation and the resulting
API ID and endpoint changes before applying.

`cognito` accepts optional `domain_prefix` to create a hosted OAuth domain.
The existing client supports authorization code flow and `openid`, `email`,
and `profile` scopes. Configure actual callback URLs and have the frontend
use PKCE, exchange its code, and send an access token to the API. A hosted
domain alone does not implement a frontend or redirect API requests to login.

## Shared EFS access points

`efs` creates the file system and mount targets only. Use a separate
`efs-access-point` module call for each service, passing the same
`file_system_id` and a different `root_directory_path`. Each call accepts
`name`, optional `uid`/`gid` (default 1000), `permissions` (default `"0755"`),
and `tags`, and exposes its access point ID and ARN. Access points do not
create file systems or mount targets.

Existing callers must migrate the former `aws_efs_access_point.this[0]`
resource into the new module before applying. Preserve its `/data` path and
POSIX settings when importing it to avoid replacement; directory contents are
not moved to new service paths automatically.

## VPC usage

Every public module accepts an optional `tags` map. Use it to identify the
project, environment, owner, and cost center from the root configuration. Module
resource names remain controlled by their existing name inputs, while each
resource retains its own `Name` tag.

```hcl
module "vpc" {
	source = "./vpc"

	name                 = "billing-production"
	vpc_cidr             = "10.0.0.0/16"
	azs                  = ["ap-southeast-1a", "ap-southeast-1b"]
	public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
	private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
	single_nat_gateway   = true
	create_flow_log      = true
	tags = {
		Project     = "billing"
		Environment = "production"
		Owner       = "platform"
		CostCenter  = "engineering"
	}
}
```

Each module call creates one VPC, its public/private subnets, route tables,
NAT gateway(s), and one network ACL shared by all its public and private subnets.
Set `network_acl_rules` to configure the ACL's ingress and egress rules. Create
another module call for each additional VPC.
Optional inputs separately configure routing, flow logs, NAT behavior, and tags.
Outputs such as `vpc_id`,
`public_subnet_ids`, and `private_subnet_ids` return that VPC's values directly.

`network_acl_rules` is a flat list: ingress CIDRs match packet sources and egress
CIDRs match packet destinations. The same ordered rules apply to every associated
subnet; a single NACL cannot enforce a different rule set based on subnet ID.
Rule numbers must be unique per direction. Use security groups or separate NACLs
if subnet-level policies must differ.

The default allows all IPv4 traffic in both directions. To customize it:

```hcl
network_acl_rules = [
  { rule_number = 100, egress = false, protocol = "-1", rule_action = "allow", cidr_block = "10.0.0.0/16" },
  { rule_number = 110, egress = false, protocol = "tcp", from_port = 443, to_port = 443, rule_action = "allow", cidr_block = "198.51.100.0/24" },
  { rule_number = 100, egress = true, protocol = "-1", rule_action = "allow", cidr_block = "0.0.0.0/0" },
]
```

Route tables and route associations are independent of NACLs and are unchanged by
this setting.

## Stable resource addresses

The VPC, Client VPN, and EFS modules use availability-zone, subnet-ID, and CIDR
keys rather than list positions. Reordering an input list no longer causes
unrelated resources to be replaced. VPC and Client VPN also compose focused child
modules for their subnet/routing and logging/network concerns.
