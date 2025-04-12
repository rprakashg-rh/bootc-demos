output "publicdns" {
  description = "Public DNS of VM"
  value       = module.bootc-vm.public_dns
}