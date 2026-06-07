output "controller_public_ip" {
  value = module.controller.public_ip
}

output "target_public_ip" {
  value = module.ec2.public_ip
}
