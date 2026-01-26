resource "aws_glue_catalog_database" "db" {
  name = var.glue_database_name
}

resource "aws_glue_crawler" "crawler" {
  name          = var.glue_crawler_name
  role          = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.db.name

  s3_target {
    path = "s3://${aws_s3_bucket.datalake.bucket}/${local.raw_prefix}"
  }

  # Keep it simple: one table per prefix
  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }
}
