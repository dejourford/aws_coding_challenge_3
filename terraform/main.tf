#------------------------------------------------------------------
# EC2 (CONTROLLER)
#------------------------------------------------------------------
module "ec2" {
  source             = "./modules/ec2"
  name               = "${var.project_name}-controller"
  environment        = var.environment
  ami                = data.aws_ami.amazon_linux_2023.id
  instance_type      = "t3.small"
  subnet_id          = aws_subnet.public[0].id
  security_group_ids = [aws_security_group.jenkins.id]
  key_name           = var.key_name
  volume_size        = 30
  iam_instance_profile = aws_iam_instance_profile.s3_access.name
}

#------------------------------------------------------------------
# EC2
#------------------------------------------------------------------
module "ec2" {
  source             = "./modules/ec2"
  name               = "${var.project_name}-ec2"
  environment        = var.environment
  ami                = data.aws_ami.amazon_linux_2023.id
  instance_type      = "t3.small"
  subnet_id          = aws_subnet.public[0].id
  security_group_ids = [aws_security_group.jenkins.id]
  key_name           = var.key_name
  volume_size        = 30
}

