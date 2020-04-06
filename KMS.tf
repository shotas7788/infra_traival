resource "aws_kms_key" "traival" {
  description             = "traival Customer Master Key"
  enable_key_rotation     = true
  is_enabled              = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "traival" {
  name          = "alias/traival"
  target_key_id = aws_kms_key.traival.key_id
}
