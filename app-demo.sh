#!/bin/bash
cd ./terraform
terraform init
terraform apply -auto-approve
cd ./ansible
ansible-playbook -i aws_ec2.yaml playbook.yaml