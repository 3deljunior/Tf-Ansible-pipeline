module "network" {
  source             = "./modules/network"
  project_name       = var.project_name
  availability_zones = var.availability_zones
}

module "compute" {
  source            = "./modules/compute"
  project_name      = var.project_name
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  instance_count    = var.instance_count
  instance_type     = var.instance_type
  key_name          = var.key_name
  ssh_cidr          = var.ssh_cidr
}

module "alb" {
  source            = "./modules/alb"
  project_name      = var.project_name
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  instance_ids      = module.compute.instance_ids
}

# Allow HTTP (port 80) to EC2s ONLY from the ALB Security Group
resource "aws_security_group_rule" "allow_http_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.compute.ec2_sg_id
  source_security_group_id = module.alb.alb_sg_id
  description              = "Allow HTTP traffic only from ALB"
}