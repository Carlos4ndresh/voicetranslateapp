#+--------------------------------------------------------------------+
#|                             Variables                              |
#+--------------------------------------------------------------------+

variable "aws_access_key" {
    type        = string
    description = "Access key for AWS user"
}

variable "aws_secret_key" {
    type        = string
    description = "Secret key for AWS user"
}

variable "region" {
    default     = "us-east-2"
    type        = string
    description = "AWS Region to use"
}

variable "github_token" {
  type        = string
  description = "Github personal authentication or oauth token"
}


#+--------------------------------------------------------------------+
#|                             Providers                              |
#+--------------------------------------------------------------------+

provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region     = var.region
}

#+--------------------------------------------------------------------+
#|                              Outputs                               |
#+--------------------------------------------------------------------+

output "voice_translator_identity_pool_id" {
  value = "${aws_cognito_identity_pool.voice_translate_identity_pool.id}"
}

output "voice_translator_cloudfront_domain" {
  value = "https://${aws_cloudfront_distribution.voice_translator_cloudfront.domain_name}/voice-translator.html"
}
