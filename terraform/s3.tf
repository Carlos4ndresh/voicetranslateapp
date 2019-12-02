#+--------------------------------------------------------------------+
#|                             S3 Bucket                              |
#+--------------------------------------------------------------------+

resource "aws_s3_bucket" "voice_translator_bucket" {
  bucket = "VoiceTranslatorBucket"
  acl    = "public-read"

  website {
      index_document = "voice-translator.html"
  }

  cors_rule {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT", "POST", "HEAD"]
      allowed_origins = ["*"]
      max_age_seconds = 3600
  }

}

resource "aws_s3_bucket_policy" "get_object" {
  bucket = "${aws_s3_bucket.voice_translator_bucket.bucket}"
  policy = <<POLICY
{
  "Id": "Policy1574970528975",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1574970525465",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.voice_translator_bucket.arn}/*",
      "Principal": "*"
    }
  ]
}
POLICY
}
