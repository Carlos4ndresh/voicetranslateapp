#+--------------------------------------------------------------------+
#|                             Codebuild                              |
#+--------------------------------------------------------------------+

resource "aws_codebuild_project" "voice_translator_project" {
  name         = "VoiceTranslator"
  description  = "Codebuild project for Voice Translator"
  service_role = "${aws_iam_role.voice_translator_codebuild_role.arn}"
  
  artifacts {
      type = "NO_ARTIFACTS"
  }

  environment {
      compute_type = "BUILD_GENERAL1_SMALL"
      image        = "aws/codebuild/standard:2.0"
      type         = "LINUX_CONTAINER"
  }

  source {
      type      = "GITHUB"
      location  = "https://github.com/Carlos4ndresh/voicetranslateapp.git"
      buildspec = "buildspec-terraform.yml"
      auth {
          type     = "OAUTH"
          resource = "${var.github_token}"
      }
  }

  logs_config {
      cloudwatch_logs {
          group_name = "VoiceTranslatorCodeBuild"
          status     = "ENABLED"
      }
    
      s3_logs {
          status = "DISABLED"
      }
  }

  vpc_config {
      security_group_ids = ["${aws_security_group.voice_translator_SG.id}"]
      subnets            = ["${aws_subnet.voice_translator_private.id}"]
      vpc_id             = "${aws_vpc.voice_translator_VPC.id}"
  }
}


#+--------------------------------------------------------------------+
#|                            Codepipeline                            |
#+--------------------------------------------------------------------+
resource "aws_codepipeline" "voice_translate_pipeline" {
  name     = "VoiceTranslatorCodePipeline"
  role_arn = "${aws_iam_role.voice_translator_codepipeline_role.arn}"

  artifact_store {
    type     = "S3"
    location = "voice-translator-lambda"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "Carlos4ndresh"
        Repo       = "voicetranslateapp"
        Branch     = "infrastructure_pipeline"
        OAuthToken = "${var.github_token}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

    configuration = {
      ProjectName = "${aws_codebuild_project.voice_translator_project.name}"
    }
    }
  }
}


#+--------------------------------------------------------------------+
#|                            Codebuild Role                          |
#+--------------------------------------------------------------------+

resource "aws_iam_role" "voice_translator_codebuild_role" {
  name = "codebuildVoiceT"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloudwatch_access" {
  role       = "${aws_iam_role.voice_translator_codebuild_role.name}"
  policy_arn = "${aws_iam_policy.cloudwatch_logs.arn}"
}

resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  role       = "${aws_iam_role.voice_translator_codebuild_role.name}"
  policy_arn = "${aws_iam_policy.cf_codebuild_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "cf_secrets" {
  role       = "${aws_iam_role.voice_translator_codebuild_role.name}"
  policy_arn = "${aws_iam_policy.cf_managed_secrets.arn}"
}

resource "aws_iam_role_policy_attachment" "s3_access_codebuild" {
  role       = "${aws_iam_role.voice_translator_codebuild_role.name}"
  policy_arn = "${aws_iam_policy.s3_access.arn}"
}

resource "aws_iam_role_policy_attachment" "s3_lambda_access_codebuild" {
  role       = "${aws_iam_role.voice_translator_codebuild_role.name}"
  policy_arn = "${aws_iam_policy.s3_access_lambda.arn}"
}

resource "aws_iam_role_policy_attachment" "s3_lambda_bucket_access_codebuild" {
  role       = "${aws_iam_role.voice_translator_codebuild_role.name}"
  policy_arn = "${aws_iam_policy.s3_access_lambda_bucket.arn}"
}
#+--------------------------------------------------------------------+
#|                         Codepipeline Role                          |
#+--------------------------------------------------------------------+

resource "aws_iam_role" "voice_translator_codepipeline_role" {
  name = "VoiceTranslatorCodebuildRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy" {
  role       = "${aws_iam_role.voice_translator_codepipeline_role.name}"
  policy_arn = "${aws_iam_policy.cf_codepipeline_policy.arn}"
}