locals {
  create_cloudwatch_resources = var.create && var.log_destination_type == "cloud-watch-logs"
}
