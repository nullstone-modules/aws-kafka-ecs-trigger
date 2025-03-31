variable "app_metadata" {
  description = <<EOF
Nullstone automatically injects metadata from the app module into this module through this variable.
This variable is a reserved variable for capabilities.
EOF

  type    = map(string)
  default = {}
}

locals {
  app_security_group_id    = var.app_metadata["security_group_id"]
  app_subnet_ids           = var.app_metadata["subnet_ids"]
  app_launch_type          = var.app_metadata["launch_type"]
  app_main_container       = var.app_metadata["main_container"]
  app_task_definition_name = var.app_metadata["task_definition_name"]
  app_execution_role_name  = var.app_metadata["execution_role_name"]
}

variable "batch_size" {
  description = "Batch size caps the number of records that the Lambda function will receive. Default = 1."
  type        = number
  default     = 1
}

variable "topics" {
  type        = set(string)
  description = "Kafka topics that will trigger the ECS/Fargate application."
}

variable "starting_position" {
  type        = string
  default     = "LATEST"
  description = <<EOF
The position in the stream where AWS Lambda should start reading.
Must be one of LATEST, TRIM_HORIZON, or AT_TIMESTAMP.
Defaults to LATEST.
EOF
}
