variable "my_ip" {
    description = "IP Address block of current local machine"
    type = string
    default = "136.27.40.26/32"    
}

variable "config" {
    description = "Edge Network configuration"
    type = object({
      name = string,
      base_domain = string,
      region = string,
      ssh_key = string,
      admin_user = string,
      admin_user_password = string,

    })
    default = {
      name                = "edge-network"
      base_domain         = "sandbox597.opentlc.com",
      region              = "us-west-2",
      ssh_key             = "ec2",
      admin_user          = "admin",
      admin_user_password = "R3dh4t1!",
    }
}
