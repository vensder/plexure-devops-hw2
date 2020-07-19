output "web_server_private_ip" {
  value = aws_instance.web_server.private_ip
}

output "jump_host_public_ip" {
  value = aws_instance.jump_host.public_ip
}

output "elb_hostname" {
  value = aws_elb.plexure_elb.dns_name
}

