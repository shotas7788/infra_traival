# resource "github_repository_webhook" "traival" {
#   repository = "your-repository"

#   configuration {
#     url          = aws_codepipeline_webhook.traival.url
#     secret       = "VeryRandomStringMoreThan20Byte!"
#     content_type = "json"
#     insecure_ssl = false
#   }

#   events = ["push"]
# }