output "alb_url" {
  description = "Open this URL in your browser after Ansible finishes"
  value       = "http://${module.alb.alb_dns_name}"
}

output "ec2_public_ips" {
  description = "Public IPs of the 3 EC2 web servers"
  value       = module.compute.instance_public_ips
}