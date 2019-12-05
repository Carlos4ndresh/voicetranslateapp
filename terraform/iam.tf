#+--------------------------------------------------------------------+
#|                            IAM Policies                            |
#+--------------------------------------------------------------------+

resource "aws_iam_policy" "transcribe_access" {
  name        = "TranscribeAccessTerraform"
  description = "Policy for accessing Transcribe from Lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1574973252028",
      "Action": [
        "transcribe:StartStreamTranscription"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cloudwatch_logs" {
  name        = "CloudWatchPolicyTerraform"
  description = "Policy for creating Cloudwatch logs"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1574977779205",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "translate_access" {
    name        = "TranslateAccessTerraform"
    description = "Policy for using translate text"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1574977807172",
      "Action": [
        "translate:TranslateText"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "polly_access" {
    name        = "PollyAccessTerraform"
    description = "Policy for using Polly Synthesize Speech"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1574977841151",
      "Action": [
        "polly:SynthesizeSpeech"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "s3_access" {
    name        = "S3AccessTerraform"
    description = "Policy for Reading and placing objects in the voice translator bucket"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1574977890906",
      "Action": [
        "s3:Get*",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::voice-translator-bucket/*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "s3_access_lambda" {
    name        = "S3AccessLambdaTerraform"
    description = "Policy for Reading and placing objects in the voice translator bucket"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1574977890906",
      "Action": [
        "s3:Get*",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::voice-translator-lambda/*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "s3_access_lambda_bucket" {
    name        = "S3AccessLambdaBucketTerraform"
    description = "Policy for Reading and placing objects in the voice translator bucket"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1574977890906",
      "Action": [
        "s3:Get*",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::voice-translator-lambda"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "lambda_access_cognito" {
    name        = "LambdaAccessCognitoTerraform"
    description = "Policy for Accessing the Voice Translate Lambda"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1574977890906",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Effect": "Allow",
      "Resource": "${aws_lambda_function.voice_translator_lambda_handler.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cf_codebuild_policy" {
    name        = "CFCodebuildPolicyTerraform"
    description = "Policy for creating CF resources through cloudformation"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1575044830515",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "ec2:CreateNetworkInterfacePermission",
        "cloudfront:TagResource",
        "cloudfront:CreateDistribution",
        "cloudfront:GetDistribution",
        "cloudformation:CreateChangeSet"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cf_managed_secrets" {
    name        = "S3Access"
    description = "Policy for Reading and placing objects in the voice translator bucket"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1575044830515",
      "Action": [
        "ssm:GetParameters",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cf_codepipeline_policy" {
    name        = "CFCodebuildPolicy"
    description = "Policy for creating CF resources through cloudformation"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1575044830515",
      "Action": [
        "ec2:CreateNetworkInterface",
        "elasticbeanstalk:*",
        "ec2:*",
        "elasticloadbalancing:*",
        "autoscaling:*",
        "cloudwatch:*",
        "s3:*",
        "sns:*",
        "cloudformation:*",
        "rds:*",
        "sqs:*",
        "ecs:*",
        "lambda:InvokeFunction",
        "lambda:ListFunctions",
        "opsworks:CreateDeployment",
        "opsworks:DescribeApps",
        "opsworks:DescribeCommands",
        "opsworks:DescribeDeployments",
        "opsworks:DescribeInstances",
        "opsworks:DescribeStacks",
        "opsworks:UpdateApp",
        "opsworks:UpdateStack",
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "devicefarm:ListProjects",
        "devicefarm:ListDevicePools",
        "devicefarm:GetRun",
        "devicefarm:GetUpload",
        "devicefarm:CreateUpload",
        "devicefarm:ScheduleRun",
        "servicecatalog:ListProvisioningArtifacts",
        "servicecatalog:CreateProvisioningArtifact",
        "servicecatalog:DescribeProvisioningArtifact",
        "servicecatalog:DeleteProvisioningArtifact",
        "servicecatalog:UpdateProduct",
        "ecr:DescribeImages",
        "iam:GetRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}