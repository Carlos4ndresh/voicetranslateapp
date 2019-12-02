#+--------------------------------------------------------------------+
#|                           Lambda Handler                           |
#+--------------------------------------------------------------------+

resource "aws_lambda_function" "voice_translator_lambda_handler" {
  function_name = "VoiceTranslatorLambda"
  handler       = "app.babelfish.LambdaHandler::handleRequest"
  role          = "${aws_iam_role.voice_translator_lambda_role.arn}"
  s3_bucket     = "voice-translator-lambda"
  s3_key        = "voice-translator/lambda/voice-translator-lambda.jar"
  runtime       = "java8"
  memory_size   = 1024
  timeout       = 30

}

#+--------------------------------------------------------------------+
#|                             Lambda Role                            |
#+--------------------------------------------------------------------+

resource "aws_iam_role" "voice_translator_lambda_role" {
  name = "VoiceTranslatorLambdaRole"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "transcribe_access" {
  role       = "${aws_iam_role.voice_translator_lambda_role.name}"
  policy_arn = "${aws_iam_policy.transcribe_access.arn}"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = "${aws_iam_role.voice_translator_lambda_role.name}"
  policy_arn = "${aws_iam_policy.cloudwatch_logs.arn}"
}

resource "aws_iam_role_policy_attachment" "translate_access" {
  role       = "${aws_iam_role.voice_translator_lambda_role.name}"
  policy_arn = "${aws_iam_policy.translate_access.arn}"
}

resource "aws_iam_role_policy_attachment" "polly_access" {
  role       = "${aws_iam_role.voice_translator_lambda_role.name}"
  policy_arn = "${aws_iam_policy.polly_access.arn}"
}

resource "aws_iam_role_policy_attachment" "s3_access_lambda" {
  role       = "${aws_iam_role.voice_translator_lambda_role.name}"
  policy_arn = "${aws_iam_policy.s3_access.arn}"
}