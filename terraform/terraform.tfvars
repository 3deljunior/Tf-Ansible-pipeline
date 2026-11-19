aws_region         = "us-east-1"
project_name       = "dahab-web"
availability_zones = ["us-east-1a", "us-east-1b"]
instance_count     = 3
instance_type      = "t3.micro"
key_name           = "pops"
ssh_cidr           = "0.0.0.0/0" # Tip: replace with YOUR_IP/32 for tighter security