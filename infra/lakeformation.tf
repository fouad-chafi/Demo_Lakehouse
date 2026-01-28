#############################################
# Lake Formation admin + register S3 location
#############################################

resource "aws_lakeformation_data_lake_settings" "this" {
  admins = var.lakeformation_admin_arns
}

# Register the bucket as a Lake Formation resource
resource "aws_lakeformation_resource" "datalake_bucket" {
  arn = aws_s3_bucket.datalake.arn
}

# Give Glue role data location access (so crawler can read via LF governance)
resource "aws_lakeformation_permissions" "glue_data_location_access" {
  principal   = aws_iam_role.glue_role.arn

  data_location {
    arn = aws_lakeformation_resource.datalake_bucket.arn
  }

  permissions = ["DATA_LOCATION_ACCESS"]
}

#############################################
# LF-Tags
#############################################

resource "aws_lakeformation_lf_tag" "domain" {
  key    = "domain"
  values = ["economics"]
}

resource "aws_lakeformation_lf_tag" "sensitivity" {
  key    = "sensitivity"
  values = ["public"]
}

#############################################
# Assign LF-Tags to the created table
#
# IMPORTANT:
# The table name is created by the crawler and depends on the folder/file.
# For demo simplicity, we assume the crawler creates a table named "big_mac_index".
# If your crawler creates a different table name, update this value.
#############################################

locals {
  glue_table_name = "big_mac_index"
}

resource "aws_lakeformation_resource_lf_tags" "table_tags" {
  lf_tag {
    key   = aws_lakeformation_lf_tag.domain.key
    value = "economics"
  }

  lf_tag {
    key   = aws_lakeformation_lf_tag.sensitivity.key
    value = "public"
  }

  
    table {
      database_name = aws_glue_catalog_database.db.name
      name          = local.glue_table_name
    }
  

  depends_on = [
    aws_glue_crawler.crawler
  ]
}

#############################################
# Grant analyst SELECT via LF-Tag Policy
#############################################

resource "aws_lakeformation_permissions" "analyst_select_via_tags" {
  count     = var.create_analyst_role ? 1 : 0
  principal = aws_iam_role.analyst[0].arn

  permissions = ["SELECT", "DESCRIBE"]

  lf_tag_policy {
    resource_type = "TABLE"

    expression {
      key    = aws_lakeformation_lf_tag.domain.key
      values = ["economics"]
    }

    expression {
      key    = aws_lakeformation_lf_tag.sensitivity.key
      values = ["public"]
    }
  }

  depends_on = [
    aws_lakeformation_lf_tag_assignment.table_tags
  ]
}
