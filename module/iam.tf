locals {
  aws-managed-policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AWSLambdaInvocation-DynamoDB",
    "arn:aws:iam::aws:policy/AWSTransferFullAccess",
    "arn:aws:iam::aws:policy/AWSTransferConsoleFullAccess"
  ]

  sftp-user-role-ids = toset(aws_iam_role.sftp-user-role.*.id)

   policy-attachment-each-role = [
      for pair in setproduct(local.sftp-user-role-ids, local.aws-managed-policies): {
        role-id = pair[0]
        policy-arn = pair[1]
      }
    ]
}

resource "aws_iam_role" "logging" {
  count = var.logging-role == null ? 1 : 0
  name  = "transfer-logging-${local.name-suffix}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "transfer.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "logging" {
  count = var.logging-role == null ? 1 : 0
  name  = "transfer-logging-${local.name-suffix}"
  role  = join(",", aws_iam_role.logging.*.id)

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:DescribeLogStreams",
        "logs:CreateLogGroup",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "invocation" {
  count = var.identity-provider-type == "API_GATEWAY" ? 1 : 0
  name  = "api-gateway-invocation-${local.name-suffix}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "transfer.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "invocation" {
  count = var.identity-provider-type == "API_GATEWAY" ? 1 : 0
  name  = "api-gateway-invocation-${local.name-suffix}"
  role  = join(",", aws_iam_role.invocation.*.id)

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

# IAM when `identity_provider_type` is `API_GATEWAY`
resource "aws_iam_role" "transfer-api-gw-role" {
  count = var.identity-provider-type == "API_GATEWAY" ? 1 : 0
  name               = "transfer-api-gw-role-${local.name-suffix}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "transfer.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "transfer-api-gw-role-policy" {
  count = var.identity-provider-type == "API_GATEWAY" ? 1 : 0
  name     = "transfer-api-gw-role-policy-${local.name-suffix}"
  role     = aws_iam_role.transfer-api-gw-role[0].id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowListingOfUserFolder",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${local.s3-bucket-name}"
      ]
    },
    {
      "Sid": "HomeDirObjectAccess",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObjectVersion",
        "s3:DeleteObject",
        "s3:GetObjectVersion"
      ],
      "Resource": "arn:aws:s3:::${local.s3-bucket-name}/*"
    }
  ]
}
POLICY
}

# IAM when `identity_provider_type` is `SERVICE_MANAGED`
resource "aws_iam_role" "sftp-user-role" {
  count = length(var.sftp-users)
  name               = "sftp-user-${keys(var.sftp-users)[count.index]}-${local.name-suffix}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ${jsonencode(var.sftp-user-role-trust-services)}
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "user" {
  count = length(var.sftp-users)
  name     = "sftp-user-${keys(var.sftp-users)[count.index]}-${local.name-suffix}"
  role     = aws_iam_role.sftp-user-role[count.index].id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowListingOfUserFolder",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${local.s3-bucket-name}"
      ]
    },
    {
      "Sid": "HomeDirObjectAccess",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObjectVersion",
        "s3:DeleteObject",
        "s3:GetObjectVersion",
        "s3:GetObjectACL",
        "s3:PutObjectACL"
      ],
      "Resource": "arn:aws:s3:::${local.s3-bucket-name}/${values(var.sftp-users)[count.index]}/*"
    }
  ]
}
POLICY
}

resource "aws_transfer_user" "user" {
  count = length(var.sftp-users)
  server_id      = local.server-id
  user_name      = keys(var.sftp-users)[count.index]
  home_directory = "/${local.s3-bucket-name}/${values(var.sftp-users)[count.index]}"
  role           = aws_iam_role.sftp-user-role[count.index].arn
  tags           = local.common-tags
}

resource "aws_transfer_ssh_key" "ssh" {
  for_each  = var.sftp-users-ssh-key
  server_id = local.server-id
  user_name = each.key
  body      = each.value
  depends_on = [
    aws_transfer_user.user
  ]
}

resource "aws_iam_role_policy_attachment" "sftp-user-role-policy" {
  count      = length(var.sftp-users) * length(local.aws-managed-policies)
  role       = local.policy-attachment-each-role[count.index].role-id
  policy_arn = local.policy-attachment-each-role[count.index].policy-arn

  depends_on = [
    aws_iam_role.sftp-user-role
  ]
}

# Post-upload processing execution role
locals {
  aws-managed-policies-post-upload = [
    "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess",
    "arn:aws:iam::aws:policy/AWSTransferFullAccess",
  ]
}

resource "aws_iam_role" "post-upload" {
  name               = "sftp-post-upload-${local.name-suffix}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ${jsonencode(var.sftp-post-upload-role-trust-services)}
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "transfer-post-upload-policy" {
  count      = length(local.aws-managed-policies-post-upload)
  role       = aws_iam_role.post-upload.id
  policy_arn = local.aws-managed-policies-post-upload[count.index]
}
