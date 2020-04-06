resource "aws_ecr_repository" "traival" {
  name = "traival"
}

resource "aws_ecr_lifecycle_policy" "traival" {
  repository = aws_ecr_repository.traival.name

  policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep last 30 release tagged images",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["release"],
          "countType": "imageCountMoreThan",
          "countNumber": 30
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
EOF
}
