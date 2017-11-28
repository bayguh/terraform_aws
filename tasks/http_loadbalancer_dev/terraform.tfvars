// 環境
env = "dev"

# lb
http_lb_settings {
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

# lb listener
lb_listener_settings {
  port     = 80
  protocol = "HTTP"
}

# lb listener rule
lb_listener_rule_settings {
  priority = 100
  field    = "path-pattern"
}
condition_values = ["/*"]
