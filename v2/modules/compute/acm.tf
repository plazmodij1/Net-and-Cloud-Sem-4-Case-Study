resource "tls_private_key" "portal_key" {
  algorithm = "RSA"
  rsa_bits = 2048
}

resource "tls_self_signed_cert" "portal_cert" {
  private_key_pem = tls_private_key.portal_key.pem

  subject {
    common_name = aws_lb.main.dns_name
    organization = "Dev Lab"
  }

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "portal_cert" {
  private_key = tls_private_key.portal_key.private_key_pem
  certificate_body = tls_self_signed_cert.portal_cert.cert_pem
  
  tags = {
    Environment = var.env
    Name        = "${var.env}-self-signed-cert"
  }
}