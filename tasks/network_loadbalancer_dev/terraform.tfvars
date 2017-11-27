// 環境
env = "dev"

# lb
network_lb_settings {
  internal                   = true
  enable_deletion_protection = false
  idle_timeout               = 60
}

# lb target group
lb_target_group_settings {
  port                 = 25
  protocol             = "TCP"
  deregistration_delay = 30
  interval             = 10
  path                 = ""
  hc_port              = "traffic-port"
  hc_protocol          = "TCP"
  timeout              = 10
  healthy_threshold    = 3
  unhealthy_threshold  = 3
  matcher              = ""
}

# lb listener
lb_listener_settings {
  port     = 25
  protocol = "TCP"
}
