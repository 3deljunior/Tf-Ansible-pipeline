#!/bin/bash
cd ~/adohc/proj2/terraform
terraform init
terraform apply -auto-approve
cd ~/adohc/proj2/ansible
ansible-playbook -i aws_ec2.yaml playbook.yaml