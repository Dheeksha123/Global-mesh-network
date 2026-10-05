output "prod_a_node_private_ip" {
  value = aws_instance.prod_a_node.private_ip
}

output "dev_a_node_private_ip" {
  value = aws_instance.dev_a_node.private_ip
}

output "firewall_private_ip" {
  value = aws_instance.firewall.private_ip
}