module "bootc-vm" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.8.0"

  name                          = "bootc-vm"
  instance_count                = 1

  instance_type                 = "t2.xlarge"
  ami                           = "ami-0e2d7de5b1ede8f57"
  subnet_id                     = tolist(module.vpc.public_subnets)[0]
  key_name                      = var.config.ssh_key
  vpc_security_group_ids        = [module.public_subnet_sg.security_group_id]
  associate_public_ip_address   = true
  ipv6_addresses = null
  private_ips = ["10.0.3.141"]
  
  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 100
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp2"
      volume_size = 50
      encrypted   = false
    }
  ]
  
  tags = local.tags
}

