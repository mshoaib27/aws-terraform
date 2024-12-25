# resource "aws_security_group" "vpn_sg" {
#   name        = "vpn-security-group"
#   description = "Security group for Client VPN"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     description      = "Allow VPN traffic"
#     from_port        = 443
#     to_port          = 443
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }
# }

# #SAML Identity Provider
# resource "aws_iam_saml_provider" "vpn_saml_provider" {
#   name                   = "vpn-saml-provider"
#   saml_metadata_document = file("./Custom_SAML_2.0_application_ins-4a19992580e96889.xml")
# }

# resource "aws_ec2_client_vpn_endpoint" "vpn_endpoint" {
#   client_cidr_block     = "29.1.0.0/16"
#   server_certificate_arn = "arn:aws:acm:us-east-1:009160057181:certificate/41b5ab22-ede1-41c0-b179-8f4d17ad71c8"
#   vpc_id                 = module.vpc.vpc_id
#   authentication_options {
#     type = "federated-authentication"
#     saml_provider_arn = aws_iam_saml_provider.vpn_saml_provider.arn
#   }

#   connection_log_options {
#     enabled = true
#     cloudwatch_log_group  = aws_cloudwatch_log_group.vpn_log_group.name
#     cloudwatch_log_stream = "vpn-connection-logs"
#   }

#   security_group_ids = [aws_security_group.vpn_sg.id]

#   split_tunnel = true

#   session_timeout_hours = 8

#   tags = {
#     Name = "client-vpn-endpoint"
#   }
# }

# resource "aws_ec2_client_vpn_authorization_rule" "auth_rule" {
#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
#   target_network_cidr    = "18.1.0.0/16"
#   authorize_all_groups   = true
# }

# resource "aws_ec2_client_vpn_network_association" "vpn_association" {
#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
#   subnet_id              = element(module.vpc.private_subnets, 0)
# }

# # Create a CloudWatch Log Group for VPN Connection Logs
# resource "aws_cloudwatch_log_group" "vpn_log_group" {
#   name              = "/aws/vpn/logs"
#   retention_in_days = 30 
# }

# # Create a CloudWatch Log Stream within the Log Group
# resource "aws_cloudwatch_log_stream" "vpn_log_stream" {
#   name           = "vpn-connection-logs"
#   log_group_name = aws_cloudwatch_log_group.vpn_log_group.name
# }