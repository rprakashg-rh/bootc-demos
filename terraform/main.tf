provider "aws" {
    region = var.config.region
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_route53_zone" "this" {
  name = var.config.base_domain
}

resource "aws_key_pair" "sshkeypair" {
    key_name   = var.config.ssh_key
    public_key = file("~/.ssh/${var.config.ssh_key}.pub")
}

data "aws_ami" "latest_rhel9_ami" {
  most_recent = true
  owners      = ["309956199498"] # official AMI owner ID

  filter {
    name   = "name"
    values = ["RHEL-9.0.0_HVM-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

locals {
    vpc_cidr        = "10.0.0.0/16"
    stack_name      = var.config.name
    azs             = slice(data.aws_availability_zones.available.names, 0, 3)
    priority        = 100
    
    tags = {
        owner: "Ram Gopinathan"
        email: "ram.gopinathan@redhat.com"
        stack: local.stack_name
    }
}