resource "aws_route53_zone" "traival" {
    name = "traival.work"
}

resource "aws_route53_record" "traival" {
    zone_id = aws_route53_zone.traival.zone_id
    name = aws_route53_zone.traival.name
    type = "A"

    alias {
        name = aws_lb.traival.dns_name
        zone_id = aws_lb.traival.zone_id
        evaluate_target_health = true
    }
}

resource "aws_acm_certificate" "traival" {
    domain_name = aws_route53_record.traival.name
    subject_alternative_names = []
    validation_method = "DNS"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_route53_record" "traival_certificate" {
    name = aws_acm_certificate.traival.domain_validation_options[0].resource_record_name
    type = aws_acm_certificate.traival.domain_validation_options[0].resource_record_type
    records = [aws_acm_certificate.traival.domain_validation_options[0].resource_record_value]
    zone_id = aws_route53_zone.traival.id
    ttl = 60
}

resource "aws_acm_certificate_validation" "traival" {
    certificate_arn = aws_acm_certificate.traival.arn
    validation_record_fqdns = [aws_route53_record.traival_certificate.fqdn]
}

