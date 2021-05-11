output "elb_dns_name"{
    value = aws_elb.example.dns_name
}

## EC2를 다시 쓰면 이것도 주석 풀기
# output "instance_private_ip" {
#     value = aws_instance.example.private_ip
# }
# output "instance_public_ip" {
#     value = aws_instance.example.public_ip
# }