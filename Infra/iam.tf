############################
# Glue crawler service role
############################

data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "glue_role" {
  name               = "${var.project_name}-glue-role"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role.json
}

# Minimal permissions for Glue crawler to read S3 + write logs + access Data Catalog
data "aws_iam_policy_document" "glue_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      aws_s3_bucket.datalake.arn,
      "${aws_s3_bucket.datalake.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetCrawler",
      "glue:CreateCrawler",
      "glue:UpdateCrawler",
      "glue:StartCrawler"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "glue_inline" {
  name   = "${var.project_name}-glue-inline"
  role   = aws_iam_role.glue_role.id
  policy = data.aws_iam_policy_document.glue_role_policy.json
}

############################
# Analyst role (demo)
############################

data "aws_iam_policy_document" "analyst_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.arn]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "analyst" {
  count              = var.create_analyst_role ? 1 : 0
  name               = var.analyst_role_name
  assume_role_policy = data.aws_iam_policy_document.analyst_assume_role.json
}

# Athena requires S3 access to write query results
data "aws_iam_policy_document" "analyst_policy" {
  statement {
    effect = "Allow"
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:GetWorkGroup",
      "athena:ListWorkGroups",
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "lakeformation:GetDataAccess"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [aws_s3_bucket.datalake.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts"
    ]
    resources = [
      "${aws_s3_bucket.datalake.arn}/${local.athena_prefix}*",
      "${aws_s3_bucket.datalake.arn}/${local.athena_prefix}*/*",
      "${aws_s3_bucket.datalake.arn}/${local.raw_prefix}*",
      "${aws_s3_bucket.datalake.arn}/${local.raw_prefix}*/*"
    ]
  }
}

resource "aws_iam_role_policy" "analyst_inline" {
  count  = var.create_analyst_role ? 1 : 0
  name   = "${var.project_name}-analyst-inline"
  role   = aws_iam_role.analyst[0].id
  policy = data.aws_iam_policy_document.analyst_policy.json
}

locals {
  analyst_principal_arn = var.create_analyst_role ? aws_iam_role.analyst[0].arn : null
}
