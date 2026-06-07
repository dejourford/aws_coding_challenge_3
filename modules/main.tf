#------------------------------------------------------------------
# EC2
#------------------------------------------------------------------
resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  user_data              = var.user_data
  iam_instance_profile = var.iam_instance_profile != "" ? var.iam_instance_profile : null

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
    encrypted   = true
  }

  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

#------------------------------------------------------------------
# IAM INSTANCE
#------------------------------------------------------------------

