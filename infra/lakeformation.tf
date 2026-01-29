#############################################
# Lake Formation admin + register S3 location
#############################################

resource "aws_lakeformation_data_lake_settings" "this" {
  admins = var.lakeformation_admin_arns
}

resource "aws_lakeformation_resource" "datalake_bucket" {
  arn = aws_s3_bucket.datalake.arn
}

resource "aws_lakeformation_permissions" "glue_data_location_access" {
  principal = aws_iam_role.glue_role.arn

  data_location {
    arn = aws_lakeformation_resource.datalake_bucket.arn
  }

  permissions = ["DATA_LOCATION_ACCESS"]
}

#############################################
# LF-Tag keys (GLOBAL in account+region)
#############################################

# Create them only once per account/region.
# For subsequent runs/environments, keep create_lf_tags=false.
resource "aws_lakeformation_lf_tag" "domain" {
  count  = var.create_lf_tags ? 1 : 0
  key    = "domain"
  values = ["economics"]
}

resource "aws_lakeformation_lf_tag" "sensitivity" {
  count  = var.create_lf_tags ? 1 : 0
  key    = "sensitivity"
  values = ["public"]
}

#############################################
# Assign LF-Tags to the Glue table
#############################################

locals {
  # Better: make this a variable later (glue_table_name)
  glue_table_name = "big_mac_index"

  # Use literal keys so we don't depend on the resources existing in state
  lf_domain_key      = "domain"
  lf_sensitivity_key = "sensitivity"
}

resource "aws_lakeformation_resource_lf_tags" "table_tags" {
  count = var.enable_lf_table_governance ? 1 : 0

  lf_tag {
    key   = local.lf_domain_key
    value = "economics"
  }

  lf_tag {
    key   = local.lf_sensitivity_key
    value = "public"
  }

  table {
    database_name = aws_glue_catalog_database.db.name
    name          = local.glue_table_name
  }

  # Ensure crawler is created (and ideally has run) before tagging
  depends_on = [
    aws_glue_crawler.crawler
  ]
}

#############################################
# Grant analyst SELECT via LF-Tag policy
#############################################

resource "aws_lakeformation_permissions" "analyst_select_via_tags" {
  count     = var.enable_lf_table_governance ? 1 : 0
  principal = aws_iam_role.analyst[0].arn

  permissions = ["SELECT", "DESCRIBE"]

  lf_tag_policy {
    resource_type = "TABLE"

    expression {
      key    = local.lf_domain_key
      values = ["economics"]
    }

    expression {
      key    = local.lf_sensitivity_key
      values = ["public"]
    }
  }

  depends_on = [
    aws_lakeformation_resource_lf_tags.table_tags
  ]
}
# Allow Glue crawler role to create/update tables in the governed database

resource "aws_lakeformation_permissions" "glue_db_permissions" {
  principal = aws_iam_role.glue_role.arn

  database {
    name = aws_glue_catalog_database.db.name
  }

  permissions = [
    "CREATE_TABLE",
    "ALTER",
    "DROP",
    "DESCRIBE"
  ]

  depends_on = [
    aws_lakeformation_data_lake_settings.this
  ]
}
