output "jumpserverpublicip"{
    value = aws_instance.example.public_ip
}
# output "albdnsname"{
#     value = aws_lb.pub-alb.dns_name
# }
output "pubsubnet1id"{
    value = aws_subnet.public1.id
}
output "pubsubnet2id"{
    value = aws_subnet.public2.id
}