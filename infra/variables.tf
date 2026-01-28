variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "project_name" {
  type        = string
  description = "Project/name prefix for resources"
  default     = "Lakehouse-demo"
}

variable "s3_bucket_name" {
  type        = string
  description = "Optional fixed bucket name. If empty, Terraform will generate one with account id."
  default     = ""
}

variable "glue_database_name" {
  type        = string
  default     = "demo_datalake"
}

variable "glue_crawler_name" {
  type        = string
  default     = "demo_bigmac_crawler"
}

variable "athena_workgroup_name" {
  type        = string
  default     = "demo-wg"
}

# Lake Formation: who is allowed to administer LF settings in the account.
# Put your own IAM role/user ARN here.
variable "lakeformation_admin_arns" {
  type        = list(string)
  description = "List of IAM principal ARNs to be Lake Formation admins (e.g., your role/user)"
}

# Optional: If you already have a role you want to use as 'analyst', set this and set create_analyst_role=false
variable "create_analyst_role" {
  type        = bool
  default     = true
}

variable "analyst_role_name" {
  type        = string
  default     = "demo-analyst-role"
}

variable "enable_table_tagging" {
  type        = bool
  description = "Enable LF tag assignment to the Glue table (requires the table to already exist)."
  default     = false
}

variable "enable_lf_table_governance" {
  type        = bool
  description = "Enable LF tag assignment and permissions on Glue tables"
  default     = false
}
