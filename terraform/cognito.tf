#+--------------------------------------------------------------------+
#|                              Cognito                               |
#+--------------------------------------------------------------------+

resource "aws_cognito_identity_pool" "voice_translate_identity_pool" {
  identity_pool_name               = "VoiceTranslatePool"
  allow_unauthenticated_identities = true
}

resource "aws_cognito_identity_pool_roles_attachment" "voice_translate_roles_attachment" {
  identity_pool_id = "${aws_cognito_identity_pool.voice_translate_identity_pool.id}"
  
  roles = {
      "unauthenticated" = "${aws_iam_role.voice_translator_cognito_unauthorized_role.arn}"
  }
}

#+--------------------------------------------------------------------+
#|                           Cognito Role                             |
#+--------------------------------------------------------------------+

resource "aws_iam_role" "voice_translator_cognito_unauthorized_role" {
  name = "CognitoUnauthorizedRole"

    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_access_cognito" {
  role       = "${aws_iam_role.voice_translator_cognito_unauthorized_role.name}"
  policy_arn = "${aws_iam_policy.s3_access.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_access_cognito" {
  role       = "${aws_iam_role.voice_translator_cognito_unauthorized_role.name}"
  policy_arn = "${aws_iam_policy.lambda_access_cognito.arn}"
}