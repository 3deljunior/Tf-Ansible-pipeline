# Dahab Web Infrastructure

An AWS infrastructure and configuration-management portfolio project. Terraform provisions a small web tier behind an Application Load Balancer; Ansible installs Nginx and deploys a templated page to the instances.

## Architecture

```text     
Internet
   |
   v
Application Load Balancer (HTTP :80)
   |
   +---- EC2 web server 1
   +---- EC2 web server 2       Ansible installs Nginx
   +---- EC2 web server 3       and deploys the page
          (public subnets)
```

Terraform creates a VPC, two public subnets, an Internet Gateway, security groups, three EC2 instances and an ALB. The EC2 instances are registered with the ALB target group. Ansible discovers running instances by their `Role=WebServer` tag and configures them.

## Repository layout

- `terraform/` — root Terraform configuration and `network`, `compute` and `alb` modules.
- `ansible/` — AWS EC2 dynamic inventory, playbook, roles and the web page template.

## Prerequisites

- An AWS account and AWS CLI credentials configured through an AWS profile or environment variables.
- Terraform `>= 1.5.0`.
- Python 3 and Ansible.
- An existing EC2 key pair in the configured AWS region. You need its **key pair name** for Terraform and its private key locally for Ansible SSH access.

Use an AWS identity with permissions to create and inspect the VPC, subnet, routing, security group, EC2 and load-balancer resources in this project. The Ansible inventory also needs permission to describe EC2 instances.

## Deploy

### 1. Provision AWS resources

From the repository root, set the key pair name and restrict SSH to your own public IP address. Do not use `0.0.0.0/0` for SSH.

```bash
cd terraform
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan \
  -var="key_name=YOUR_EXISTING_KEY_PAIR_NAME" \
  -var="ssh_cidr=YOUR_PUBLIC_IP/32" \
  -out=tfplan
terraform apply tfplan
```

The AWS region defaults to `us-east-1`. The Ansible inventory is also configured for `us-east-1`; if you change regions, update `ansible/aws_ec2.yaml` to match.

After applying, Terraform prints the ALB URL and EC2 public IPs:

```bash
terraform output
```

### 2. Configure the web servers

Install Ansible and its AWS inventory dependencies in your preferred Python environment:

```bash
python3 -m pip install ansible boto3 botocore
ansible-galaxy collection install amazon.aws
```

Before running Ansible, update `ansible/ansible.cfg`:

- Set `private_key_file` to the path of your local private key for the EC2 key pair. Never put the key in Git.
- Replace the machine-specific absolute paths with paths appropriate for your checkout.
- Enable SSH host-key checking for safer connections.

From the repository root, run:

```bash
ANSIBLE_CONFIG=ansible/ansible.cfg \
  ansible-playbook -i ansible/aws_ec2.yaml ansible/playbook.yaml
```

The inventory uses your AWS credentials to find running instances tagged `Role=WebServer`. Ansible connects as `ubuntu`, installs baseline packages and Nginx, then deploys the page from `ansible/roles/app/templates/index.html.j2`.

When Ansible completes, open the `alb_url` Terraform output in a browser. The ALB health check expects HTTP on port 80.

## Clean up

Destroy the resources when finished to avoid ongoing AWS charges:

```bash
cd terraform
terraform destroy \
  -var="key_name=YOUR_EXISTING_KEY_PAIR_NAME" \
  -var="ssh_cidr=YOUR_PUBLIC_IP/32"
```

Review the destroy plan before confirming. The EC2 key pair itself is an existing prerequisite and is not created by this project.

## Security and cost notes

- This is a learning project, not a production-ready deployment. The instances are in public subnets and receive public IP addresses; SSH access should be restricted to a trusted IP.
- The ALB accepts plain HTTP, not HTTPS. Do not use this setup for sensitive production traffic.
- Terraform state and private keys must remain local or be stored in appropriately secured systems. Do not commit state files, private keys, credentials, or plans. If a private key has already been published, revoke it and create a replacement.
- The project creates billable AWS resources, including an ALB and EC2 instances. Destroy them when you are done.

## Possible next steps

- Put application instances in private subnets and use Systems Manager Session Manager or another controlled access method.
- Add HTTPS with an AWS Certificate Manager certificate.
- Add an Auto Scaling Group, remote and protected Terraform state, and CI checks for Terraform and Ansible.

