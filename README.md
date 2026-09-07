# 🚀 Terraform AWS Architecture Series

Welcome to the **Terraform AWS Architecture Series** repository! This repository is structured as a progressive hands-on laboratory for designing, provisioning, and scaling production-ready AWS cloud infrastructure using Infrastructure as Code (IaC) with Terraform.

Each directory in this repository represents an independent, self-contained architecture pattern.

---

## 🗺️ Repository Architecture Roadmap

```
terraform-aws-architecture-series/
│
├── 📁 01-vpc-ec2-web-server              <-- (Active Architecture)
├── 📁 02-vpc-public-private-subnets      (Upcoming)
├── 📁 03-three-tier-web-application      (Upcoming)
├── 📁 04-alb-auto-scaling                (Upcoming)
├── 📁 05-rds-high-availability           (Upcoming)
├── 📁 06-nat-gateway-private-ec2         (Upcoming)
├── 📁 07-ecs-containerized-application   (Upcoming)
├── 📁 08-serverless-web-application      (Upcoming)
└── 📁 09-production-ready-architecture   (Upcoming)
```

---

## 📐 Architecture 01: Custom VPC with EC2 Web Server

> **Directory**: [`./01-vpc-ec2-web-server`](./01-vpc-ec2-web-server)

### System Design Diagram

```
+-----------------------------------------------------------------------------------+
|                                     AWS Cloud                                     |
|                                                                                   |
|  +-----------------------------------------------------------------------------+  |
|  |                     VPC: terraform-learning-vpc (10.0.0.0/16)                |  |
|  |                                                                             |  |
|  |  +-----------------------------------------------------------------------+  |  |
|  |  |            Public Subnet: terraform-public-subnet (10.0.1.0/24)       |  |  |
|  |  |                                                                       |  |  |
|  |  |   +---------------------------------------------------------------+   |  |  |
|  |  |   |             Security Group: terraform-web-sg                  |   |  |  |
|  |  |   |                                                               |   |  |  |
|  |  |   |   +-------------------------------------------------------+   |   |  |  |
|  |  |   |   |       EC2 Instance: terraform-learning                |   |   |  |  |
|  |  |   |   |       - OS: Ubuntu 24.04 LTS (Noble Numbat)           |   |   |  |  |
|  |  |   |   |       - Type: var.instance_type (e.g. t2.micro)       |   |   |  |  |
|  |  |   |   |       - Key Pair: terraform-key                       |   |   |  |  |
|  |  |   |   +-------------------------------------------------------+   |   |  |  |
|  |  |   |        ▲ SSH (Port 22)   ▲ HTTP (Port 80)  ▲ HTTPS (Port 443)|   |  |  |
|  |  |   +--------|-----------------|-----------------|--------------+   |  |  |
|  |  +------------|-----------------|-----------------|----------------------+  |  |
|  |               |                 |                 |                         |  |
|  |               |                 ▼                 ▼                         |  |
|  |  +------------|----------------------------------------------------------+  |  |
|  |  | Route Table| terraform-public-route-table                             |  |  |
|  |  | Destination| 0.0.0.0/0 ---> Internet Gateway                          |  |  |
|  |  +------------|----------------------------------------------------------+  |  |
|  |               |                                                             |  |
|  |               ▼                                                             |  |
|  |  +-----------------------------------------------------------------------+  |  |
|  |  | Internet Gateway: terraform-learning-igw                              |  |  |
|  |  +-----------------------------------------------------------------------+  |  |
|  +-----------------------------------|-----------------------------------------+  |
+--------------------------------------|--------------------------------------------+
                                       │
                                       │ Internet Traffic
                                       ▼
                        +------------------------------+
                        |      Administrator / Client   |
                        +------------------------------+
```

### Infrastructure Flow (Mermaid Diagram)

```mermaid
graph TD
    Client[Client / Administrator] -->|SSH: Port 22| IGW[Internet Gateway]
    Client -->|HTTP/HTTPS: 80, 443| IGW
    
    subgraph VPC ["VPC: 10.0.0.0/16"]
        IGW --> RT[Public Route Table]
        
        subgraph Public Subnet ["Public Subnet: 10.0.1.0/24"]
            RT --> SG[Security Group: terraform-web-sg]
            
            subgraph Security Group Rules
                SG -->|Allow 22 from SSH IP| EC2[EC2 Instance: Ubuntu 24.04]
                SG -->|Allow 80/443 from Anywhere| EC2
            end
        end
    end

    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:white;
    classDef compute fill:#EC7211,stroke:#232F3E,stroke-width:2px,color:white;
    classDef network fill:#147EBA,stroke:#232F3E,stroke-width:2px,color:white;
    
    class VPC network;
    class EC2 compute;
    class IGW aws;
```

---

## 💻 Quick Start & Deployment Guide

### 1. Provision Architecture 01
Navigate to the directory of module 01:
```bash
cd 01-vpc-ec2-web-server
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Review Plan & Apply
```bash
# For Development environment
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"

# For Production environment
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

### 4. Clean Up / Destroy
```bash
terraform destroy -var-file="dev.tfvars"
```

---

## 🏷️ Variables Reference (Module 01)

| Variable | Type | Description |
| :--- | :--- | :--- |
| `region` | `string` | The target AWS Region (e.g., `us-east-1`, `ap-south-1`) |
| `instance_type` | `string` | EC2 instance sizing (e.g., `t2.micro`, `t3.medium`) |
| `environment` | `string` | Tag identifying deployment stage (`dev` / `prod`) |
| `my_ip` | `string` | IP address allowed to SSH into the EC2 instance |

---

## 📜 License
This project is open-source under the MIT License.
