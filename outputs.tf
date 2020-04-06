
output "alb_dns_name" {
  value = aws_lb.traival.dns_name
}

output "domain_name" {
    value = aws_route53_record.traival.name
}

output "operation_instance_id" {
  value = aws_instance.traival_for_operation.id
}
