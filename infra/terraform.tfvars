#############################################
# Global
#############################################

aws_region   = "eu-central-1"
project_name = "aws-demo-datalake-v2"

# Optional: leave empty to auto-generate bucket name with account id
# s3_bucket_name = "aws-demo-datalake-eu-central-1-123456789012"

#############################################
# Lake Formation
#############################################

# IMPORTANT:
# These principals will be FULL Lake Formation admins.
# Include:
# 1) Your own IAM role / SSO role (so you can manage LF in console)
# 2) The GitHub Actions role (so CI can apply LF resources)

lakeformation_admin_arns = [
  "arn:aws:iam::637423545678:role/FouadLFAdmin",
  "arn:aws:iam::637423545678:role/github-actions-terraform-role"
]

#############################################
# Glue
#############################################

glue_database_name = "demo_datalake-v2"
glue_crawler_name  = "demo_bigmac_crawler-v2"

#############################################
# Athena
#############################################

athena_workgroup_name = "demo-wg"

#############################################
# Analyst role (demo consumer of data)
#############################################

# Set to false if you want to use an existing role instead
create_analyst_role = true

# Only used if create_analyst_role = true
analyst_role_name = "demo-analyst-role-v2"



enable_lf_table_governance = true
create_lf_tags             = false
