// 環境
env = "dev"

# lb
https_lb_settings {
  internal                   = false
  enable_deletion_protection = false
  idle_timeout               = 60
  access_logs_enabled        = true
}

# lb target group
lb_target_group_settings {
  port                       = 80
  protocol                   = "HTTP"
  deregistration_delay       = 30
  stickiness_type            = "lb_cookie"
  stickiness_cookie_duration = 3600
  stickiness_enabled         = true
  interval                   = 10
  path                       = "/"
  hc_port                    = "traffic-port"
  hc_protocol                = "HTTP"
  timeout                    = 5
  healthy_threshold          = 3
  unhealthy_threshold        = 3
  matcher                    = "200"
}

# lb target group attachment
lb_target_group_attachment_settings {
  port = 80
}

# iam server certificate
iam_server_certificate_settings {
  name                   = "test-cert"
  certificate_body_path  = "../../keys/ssl/certificate.pem"
  certificate_chain_path = "../../keys/ssl/chain_certificate.pem"
  private_key_path       = "../../keys/ssl/private.key"
}

# lb listener
lb_listener_settings {
  port       = 443
  protocol   = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
}

# lb listener rule
lb_listener_rule_settings {
  priority = 100
  field    = "path-pattern"
}
condition_values = ["/*"]
