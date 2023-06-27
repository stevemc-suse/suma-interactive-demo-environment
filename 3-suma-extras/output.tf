output "suma-proxy_ip" {
  value = aws_instance.suma-proxy.private_ip
}

output "suma-monsrv_ip" {
  value = aws_instance.suma-monsrv.private_ip
}

#output "suma-server_ip" {
#  value = aws_instance.suma.public_ip
#}