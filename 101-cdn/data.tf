#to retrieve information about a CloudFront cache policy.
data "aws_cloudfront_cache_policy" "noCache" {
  name = "Managed-CachingDisabled"          # for dynamic content disable cache 
}

data "aws_cloudfront_cache_policy" "cacheOptimize" {
  name = "Managed-CachingOptimized"          
}

data "aws_ssm_parameter" "https_certificate_arn" {
  name = "/${var.project_name}/${var.environment}/https_certificate_arn"
}