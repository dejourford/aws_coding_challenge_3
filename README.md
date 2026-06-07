# AWS Coding Challenge 3

## Objective
Provision AWS infrastructure using **Terraform** and configure a web server using **Ansible** to deploy a simple "Hello, World!" web page.

## Tools Used
- **Terraform** — provisioning AWS infrastructure (EC2 instances, S3 bucket, VPC, IAM roles, security groups)
- **Ansible** — configuring the target EC2 instance and deploying the web application
- **Nginx** — web server serving the Hello, World! page
- **AWS EC2** — two instances: one controller (runs Ansible) and one target (hosts the web server)
- **AWS S3** — storage bucket with IAM permissions for upload/download
- **GitHub** — version control

## Prerequisites

Before getting started, ensure you have the following installed and configured:

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) — configured with `aws configure`
- [Terraform](https://developer.hashicorp.com/terraform/install) — v1.0+
- An AWS account with appropriate IAM permissions
- A key pair created in AWS EC2

## Getting Started

Clone the repository and navigate into it:

```
git clone https://github.com/dejourford/aws_coding_challenge_3.git
cd aws_coding_challenge_3
```

## Procedure

### Phase 1 - Provision Infrastructure with Terraform

Step 1.1 - Navigate into the terraform directory

```
cd terraform
```

Step 1.2 - Update `variables.tf` with your values

```hcl
variable "project_name" { default = "<your-project-name>" }
variable "region"       { default = "<your-region>" }
variable "key_name"     { default = "<your-key-pair-name>" }
```

Step 1.3 - Initialize and apply Terraform

```
terraform init
terraform apply
```

Step 1.4 - Note the outputs — you will need these in later steps

```
terraform output
```

This will display the public IPs for both EC2 instances:
- `controller_public_ip` — the Ansible controller
- `target_public_ip` — the web server target


### Phase 2 - Configure Ansible on the Controller

Step 2.1 - SSH into the controller EC2

```
ssh -i ~/.ssh/<your-key-pair>.pem ec2-user@<controller_public_ip>
```

Step 2.2 - Install Ansible

```
sudo dnf install ansible -y
```

Step 2.3 - Copy your key pair from your local machine to the controller so it can SSH into the target

```
scp -i ~/.ssh/<your-key-pair>.pem ~/.ssh/<your-key-pair>.pem ec2-user@<controller_public_ip>:~/.ssh/<your-key-pair>.pem
```

Step 2.4 - Set correct permissions on the key pair

```
chmod 400 ~/.ssh/<your-key-pair>.pem
```

Step 2.5 - Create an inventory file pointing to the target EC2

```
nano ~/inventory.ini
```

Add the following:

```ini
[webservers]
<target_public_ip> ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/<your-key-pair>.pem
```

Step 2.6 - Test the connection to the target

```
ansible -i ~/inventory.ini webservers -m ping
```

You should see a `pong` response confirming connectivity.


### Phase 3 - Deploy the Web Server with Ansible

Step 3.1 - Create the Ansible playbook on the controller

```
nano ~/playbook.yml
```

Add the following:

```yaml
---
- name: Configure web server
  hosts: webservers
  become: yes

  tasks:
    - name: Install Nginx
      dnf:
        name: nginx
        state: present

    - name: Start and enable Nginx
      systemd:
        name: nginx
        state: started
        enabled: yes

    - name: Deploy Hello World page
      copy:
        content: "<html><body><h1>Hello, World!</h1></body></html>"
        dest: /usr/share/nginx/html/index.html
        owner: nginx
        group: nginx
        mode: '0644'
```

Step 3.2 - Run the playbook

```
ansible-playbook -i ~/inventory.ini ~/playbook.yml
```

Step 3.3 - Navigate to `http://<target_public_ip>` in your browser to verify "Hello, World!" is displayed


## Terraform Code Overview

### modules/ec2
A reusable EC2 module that accepts variables for AMI, instance type, subnet, security groups, key pair, user data, and volume size. Called twice — once for the controller and once for the target.

### vpc.tf
Provisions a VPC with public subnets, an internet gateway, and route tables to allow public internet access.

### sg.tf
Security group allowing inbound traffic on ports 22 (SSH), 80 (HTTP), and 443 (HTTPS).

### s3.tf
An S3 bucket with versioning, server-side encryption, and public access blocked. Includes an IAM role and instance profile allowing EC2 instances to upload and download objects.

### variables.tf
Input variables for project name, environment, region, VPC CIDR, instance type, and key pair name.

### outputs.tf
Outputs the public IPs of both EC2 instances after apply.


## Ansible Playbook Overview

The playbook targets the `[webservers]` group defined in the inventory file and performs three tasks:

1. **Install Nginx** — uses the `dnf` module to install Nginx on Amazon Linux 2023
2. **Start and enable Nginx** — uses the `systemd` module to start the service and enable it on boot
3. **Deploy Hello World page** — uses the `copy` module to write a simple HTML page to the Nginx web root


## Conclusion
This project demonstrated how Terraform and Ansible complement each other in a real-world infrastructure workflow. Terraform handled the provisioning of all AWS resources while Ansible handled the configuration and application deployment — keeping infrastructure-as-code and configuration management cleanly separated. Using a dedicated controller EC2 to run Ansible playbooks against a target server mirrors how Ansible is used in production environments.

## Lessons Learned
- **Terraform modules improve reusability** — creating a reusable EC2 module eliminated duplicated code and made provisioning multiple instances clean and consistent.
- **Ansible requires SSH access** — the controller needs the private key to reach the target, which means securely copying the key pair to the controller before running playbooks.
- **Separation of concerns** — Terraform provisions, Ansible configures. Keeping these responsibilities separate makes the project easier to maintain and reason about.
- **Amazon Linux 2023 uses dnf** — unlike Ubuntu which uses apt, AL2023 uses dnf for package management, which affects both Terraform user_data scripts and Ansible playbook tasks.
- **Inventory files define Ansible targets** — the inventory file is the bridge between Ansible and the infrastructure, mapping host groups to IP addresses and connection details.
