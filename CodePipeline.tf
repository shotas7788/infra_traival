# data "aws_iam_policy_document" "codepipeline" {
#   statement {
#     effect    = "Allow"
#     resources = ["*"]

#     actions = [
#       "s3:PutObject",
#       "s3:GetObject",
#       "s3:GetObjectVersion",
#       "s3:GetBucketVersioning",
#       "codebuild:BatchGetBuilds",
#       "codebuild:StartBuild",
#       "ecs:DescribeServices",
#       "ecs:DescribeTaskDefinition",
#       "ecs:DescribeTasks",
#       "ecs:ListTasks",
#       "ecs:RegisterTaskDefinition",
#       "ecs:UpdateService",
#       "iam:PassRole",
#     ]
#   }
# }

# module "codepipeline_role" {
#   source     = "./iam_role"
#   name       = "codepipeline"
#   identifier = "codepipeline.amazonaws.com"
#   policy     = data.aws_iam_policy_document.codepipeline.json
# }

# resource "aws_codepipeline" "traival" {
#   name     = "traival"
#   role_arn = module.codepipeline_role.iam_role_arn

#   stage {
#     name = "Source"

#     action {
#       name             = "Source"
#       category         = "Source"
#       owner            = "ThirdParty"
#       provider         = "GitHub"
#       version          = 1
#       output_artifacts = ["Source"]

#       configuration = {
#         Owner                = "your-github-name"
#         Repo                 = "your-repository"
#         Branch               = "master"
#         PollForSourceChanges = false
#       }
#     }
#   }

#   stage {
#     name = "Build"

#     action {
#       name             = "Build"
#       category         = "Build"
#       owner            = "AWS"
#       provider         = "CodeBuild"
#       version          = 1
#       input_artifacts  = ["Source"]
#       output_artifacts = ["Build"]

#       configuration = {
#         ProjectName = aws_codebuild_project.traival.id
#       }
#     }
#   }

#   stage {
#     name = "Deploy"

#     action {
#       name            = "Deploy"
#       category        = "Deploy"
#       owner           = "AWS"
#       provider        = "ECS"
#       version         = 1
#       input_artifacts = ["Build"]

#       configuration = {
#         ClusterName = aws_ecs_cluster.traival.name
#         ServiceName = aws_ecs_service.traival.name
#         FileName    = "imagedefinitions.json"
#       }
#     }
#   }

#   artifact_store {
#     location = aws_s3_bucket.artifact.id
#     type     = "S3"
#   }
# }

# resource "aws_codepipeline_webhook" "traival" {
#   name            = "traival"
#   target_pipeline = aws_codepipeline.traival.name
#   target_action   = "Source"
#   authentication  = "GITHUB_HMAC"

#   authentication_configuration {
#     secret_token = "VeryRandomStringMoreThan20Byte!"
#   }

#   filter {
#     json_path    = "$.ref"
#     match_equals = "refs/heads/{Branch}"
#   }
# }
