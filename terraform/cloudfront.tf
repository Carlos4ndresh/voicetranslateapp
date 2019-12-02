#+--------------------------------------------------------------------+
#|                            Cloudfront                              |
#+--------------------------------------------------------------------+

resource "aws_cloudfront_distribution" "voice_translator_cloudfront" {
  origin {
      domain_name = "${aws_s3_bucket.voice_translator_bucket.bucket_regional_domain_name}"
      origin_id = "s3-origin-${aws_s3_bucket.voice_translator_bucket.bucket}"
  }
  
  default_cache_behavior {
      allowed_methods        = ["HEAD", "GET"]
      cached_methods         = ["HEAD", "GET"]
      target_origin_id       = "s3-origin-${aws_s3_bucket.voice_translator_bucket.bucket}"
      viewer_protocol_policy = "redirect-to-https"
      default_ttl            = 0
      compress               = false

    forwarded_values {
        headers = ["Origin"]
        query_string = false

        cookies {
            forward = "none"
        } 
    }
  }
  
  restrictions {
      geo_restriction{
        restriction_type = "none"
      }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  enabled                = true
  is_ipv6_enabled        = false
  http_version           = "http1.1"
  price_class            = "PriceClass_All"
  default_root_object    = "index.html"
}
