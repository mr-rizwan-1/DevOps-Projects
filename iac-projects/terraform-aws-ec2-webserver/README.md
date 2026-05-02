# 🏗️ IaC Deployment: AWS EC2 Web Server with Terraform

> Automate the deployment of a **live Apache web server on AWS EC2** using Terraform.  
> Infrastructure is provisioned on AWS **Default VPC** with a dedicated Security Group, EC2 Key Pair, and Apache installed via a remote-exec provisioner.  
> Terraform state is stored remotely in **AWS S3** for safe and consistent state management.

---

## 📌 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Infrastructure Resources](#infrastructure-resources)
- [Port Reference](#port-reference)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Usage](#usage)
  - [1. Clone the Repo](#1-clone-the-repo)
  - [2. Configure AWS Credentials](#2-configure-aws-credentials)
  - [3. Generate SSH Key Pair](#3-generate-ssh-key-pair)
  - [4. Update Variables](#4-update-variables)
  - [5. Initialize Terraform](#5-initialize-terraform)
  - [6. Plan & Apply](#6-plan--apply)
  - [7. Access the Web Server](#7-access-the-web-server)
  - [8. Destroy Infrastructure](#8-destroy-infrastructure)
- [How Web Server is Configured](#how-web-server-is-configured)
- [Terraform Outputs](#terraform-outputs)
- [Remote State — S3 Backend](#remote-state--s3-backend)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)

---

## 🏗️ Architecture Overview

```
  Public Internet
       │
       │  HTTP (port 80) / SSH (port 22)
       ▼
┌─────────────────────────────────────────────┐
│               AWS Cloud                      │
│                                             │
│   ┌─────────────────────────────────────┐  │
│   │           Default VPC               │  │
│   │                                     │  │
│   │  ┌───────────────────────────────┐  │  │
│   │  │   Security Group (dove-sg)    │  │  │
│   │  │  Inbound:                     │  │  │
│   │  │  • SSH  :22  → 0.0.0.0/0     │  │  │
│   │  │  • HTTP :80  → 0.0.0.0/0     │  │  │
│   │  │  Outbound: All (IPv4 + IPv6)  │  │  │
│   │  └──────────────┬────────────────┘  │  │
│   │                 │                   │  │
│   │  ┌──────────────▼────────────────┐  │  │
│   │  │  Ubuntu EC2 (Dove-Web-Server) │  │  │
│   │  │  Instance Type : t3.micro     │  │  │
│   │  │  Key Pair      : dove-key     │  │  │
│   │  │  AMI           : region-based │  │  │
│   │  │                               │  │  │
│   │  │  ┌─────────────────────────┐  │  │  │
│   │  │  │  Apache2 Web Server     │  │  │  │
│   │  │  │  + Tooplate Template    │  │  │  │
│   │  │  │  (deployed via web.sh)  │  │  │  │
│   │  │  └─────────────────────────┘  │  │  │
│   │  └───────────────────────────────┘  │  │
│   └─────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
            │ local-exec
            ▼
      instance-info.txt
  (Instance ID, Public IP, Private IP)
```

**Provisioning Flow:**
1. Terraform creates Security Group + EC2 instance
2. `file` provisioner → copies `web.sh` to EC2 at `/tmp/web.sh`
3. `remote-exec` provisioner → SSH into EC2 and runs `web.sh`
4. `web.sh` → installs Apache2 + deploys HTML template from Tooplate
5. `local-exec` provisioner → runs `save_output.sh` to save instance details locally

---

## 📦 Infrastructure Resources

| Resource | Name | Description |
|---|---|---|
| `aws_security_group` | `dove-sg` | Inbound: SSH (22), HTTP (80) — Outbound: All |
| `aws_vpc_security_group_ingress_rule` | `sshfrmomyIP_ipv4` | SSH from anywhere (0.0.0.0/0) |
| `aws_vpc_security_group_ingress_rule` | `allow_http` | HTTP from anywhere (0.0.0.0/0) |
| `aws_vpc_security_group_egress_rule` | `AllowAllOutbound_IPv4/IPv6` | All outbound traffic allowed |
| `aws_instance` | `Dove-Web-Server` | Ubuntu t3.micro — Apache via remote-exec |
| `aws_ec2_instance_state` | `web_server_state` | Ensures instance stays `running` |

> ℹ️ **Default VPC is used** — no custom VPC, Subnet, or Internet Gateway is created in this project.

---

## 🔌 Port Reference

| Port | Protocol | Purpose | Source |
|---|---|---|---|
| 22 | TCP | SSH — used by Terraform provisioner | 0.0.0.0/0 |
| 80 | TCP | HTTP — Apache Web Server | 0.0.0.0/0 |

---

## ✅ Prerequisites

Before running this project, make sure you have:

- [ ] [Terraform](https://developer.hashicorp.com/terraform/install) installed (`>= 1.0`)
- [ ] AWS CLI installed and configured
- [ ] AWS IAM user with programmatic access (EC2 + S3 permissions)
- [ ] S3 bucket created for remote state (see section below)
- [ ] SSH key pair generated locally (`dove-key`)

```bash
# Verify installations
terraform -version
aws --version
aws sts get-caller-identity   # confirms credentials are working
```

---

## 📁 Project Structure

```
terraform-aws-ec2-webserver/
├── Scripts/
│   └── save_output.sh     # Saves Instance ID, Public IP, Private IP to file
├── Backend.tf             # S3 remote state backend configuration
├── Instance.tf            # EC2 instance, provisioners, outputs
├── Keypair.tf             # AWS Key Pair resource (dove-key)
├── SecGrp.tf              # Security Group — SSH (22) + HTTP (80)
├── instID.tf              # Instance ID config
├── provider.tf            # AWS provider + region
├── vars.tf                # Variables — region, AMI map, zone, webuser
├── Outputs                # Terraform output definitions
├── web.sh                 # Apache2 install + HTML template deploy
├── webserver_ips.txt      # Auto-generated: saved IPs
├── Deployment Steps       # Manual deployment reference
├── Diagram.png            # Architecture diagram
└── README.md              # This file
```

---

## 🚀 Usage

### 1. Clone the Repo

```bash
git clone https://github.com/mr-rizwan-1/DevOps-Projects.git
cd DevOps-Projects/iac-projects/terraform-aws-ec2-webserver
```

### 2. Configure AWS Credentials

```bash
aws configure
# AWS Access Key ID     : <your-access-key>
# AWS Secret Access Key : <your-secret-key>
# Default region        : ap-south-1
# Output format         : json
```

### 3. Generate SSH Key Pair

Terraform uses SSH to run provisioners on EC2 — key must exist before `terraform apply`.

```bash
# Generate key pair
ssh-keygen -t rsa -b 4096 -f dove-key

# Creates:
# dove-key       ← private key (referenced in Instance.tf)
# dove-key.pub   ← public key (uploaded to AWS via Keypair.tf)
```

### 4. Update Variables

Edit `vars.tf` with your values:

```hcl
region = "ap-south-1"     # your AWS region
zone1  = "ap-south-1a"    # availability zone
```

> Ensure the AMI ID in `vars.tf` matches your selected region.

### 5. Initialize Terraform

```bash
terraform init
```

This will:
- Download the AWS provider plugin
- Connect to S3 backend and initialize remote state

### 6. Plan & Apply

```bash
# Preview what will be created
terraform plan

# Deploy infrastructure
terraform apply
```

Type `yes` when prompted. Terraform will:
1. Create Security Group (`dove-sg`)
2. Upload Key Pair (`dove-key`)
3. Launch EC2 instance (`Dove-Web-Server`)
4. SSH into EC2 → run `web.sh` (installs Apache + deploys website)
5. Save instance details to `instance-info.txt`

### 7. Access the Web Server

```bash
# Terraform prints public IP after apply:
# WebPublicIP = "13.233.xx.xx"

# Open in browser:
http://<WebPublicIP>

# SSH into instance:
ssh -i dove-key ubuntu@<WebPublicIP>
```

### 8. Destroy Infrastructure

```bash
terraform destroy
```

> ⚠️ This permanently deletes the EC2 instance and Security Group. S3 bucket for remote state will remain.

---

## 🌐 How Web Server is Configured

Apache is installed using Terraform **provisioners** — not user_data:

```
terraform apply
      │
      ├── file provisioner
      │     └── copies web.sh → /tmp/web.sh on EC2
      │
      ├── remote-exec provisioner
      │     └── SSH → chmod +x /tmp/web.sh → sudo /tmp/web.sh
      │
      └── local-exec provisioner
            └── runs save_output.sh → saves IPs to instance-info.txt
```

**`web.sh` does the following:**

```bash
apt update
apt install wget unzip apache2 -y   # Install Apache2
systemctl start apache2
systemctl enable apache2             # Auto-start on reboot

# Download & deploy HTML template from Tooplate
cd /tmp
wget https://www.tooplate.com/zip-templates/2150_living_parallax.zip
unzip -o 2150_living_parallax.zip
cp -r 2150_living_parallax/* /var/www/html/

systemctl restart apache2
```

Visiting `http://<EC2-IP>` shows the **Living Parallax** website live on the server.

---

## 📤 Terraform Outputs

After `terraform apply`, these values are printed and saved:

| Output | Description |
|---|---|
| `WebPublicIP` | Public IP of the EC2 instance |
| `WebPrivateIP` | Private IP of the EC2 instance |

`save_output.sh` additionally writes to `instance-info.txt`:

```
Instance ID: i-0xxxxxxxxxxxxxxx
Public IP:   13.233.xx.xx
Private IP:  172.31.xx.xx
```

---

## 🪣 Remote State — S3 Backend

Terraform state is stored in S3 for:
- **Safety** — no risk of losing local state file
- **Consistency** — single source of truth
- **Collaboration** — shareable across team

**`Backend.tf`:**

```hcl
terraform {
  backend "s3" {
    bucket = "<your-s3-bucket-name>"
    key    = "terraform-aws-ec2-webserver/terraform.tfstate"
    region = "ap-south-1"
  }
}
```

> ⚠️ Create the S3 bucket **manually before** running `terraform init`.

```bash
# One-time bucket creation
aws s3api create-bucket \
  --bucket <your-bucket-name> \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1
```

---

## 📸 Screenshots

> _Take screenshots after setup and place them in `screenshots/` folder._

| What | Screenshot |
|---|---|
| `terraform apply` output | ![apply](screenshots/terraform-apply.png) |
| Live website on EC2 (browser) | ![web](screenshots/website-live.png) |
| EC2 Instance — AWS Console | ![ec2](screenshots/ec2-console.png) |
| Security Group rules | ![sg](screenshots/security-group.png) |
| S3 bucket with tfstate file | ![s3](screenshots/s3-remote-state.png) |

**Recommended screenshots:**
```
1. Terminal   → terraform apply output (resources created)
2. Browser    → http://<EC2-IP> showing deployed website
3. AWS Console → EC2 instance in "running" state
4. AWS Console → Security Group inbound rules
5. AWS Console → S3 bucket with terraform.tfstate file
```

---

## 🛠️ Tech Stack

| Tool | Purpose |
|---|---|
| **Terraform** | Infrastructure as Code — provisioning & lifecycle |
| **AWS EC2** | Ubuntu web server (`Dove-Web-Server`, t3.micro) |
| **AWS Security Group** | Firewall — HTTP (80) + SSH (22) inbound |
| **AWS Key Pair** | SSH access for Terraform provisioner (`dove-key`) |
| **AWS S3** | Remote Terraform state backend |
| **Apache2** | Web server — installed via remote-exec provisioner |
| **Bash** | `web.sh` — Apache install + website deploy script |
| **Tooplate** | HTML website template deployed on Apache |

---

## 👤 Author

**Rizwaan Rahat** — DevOps Engineer  
🔗 [LinkedIn](https://www.linkedin.com/in/rizwaan-khan/) · [GitHub](https://github.com/mr-rizwan-1)
