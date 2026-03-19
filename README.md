# Infrastructure Documentation

This project defines the AWS infrastructure for a secure, multi-tier application environment using Terraform. The architecture utilizes a dual-VPC setup (Public and Private) to strictly isolate external-facing resources from internal backend compute and data storage services.

## Architecture Overview

The infrastructure is segmented into the following key components:

### 1. Networking
- **Public VPC**: Hosts external-facing components and entry points.
- **Private VPC**: Hosts all backend compute and data storage services without direct internet access.

### 2. Secure Remote Access
- **VPN**: A VPN server is deployed in the public VPC to provide secure administrative access to the environment. It is configured to allow:
- **SSH** SSH traffic on port 22.
- **WireGuard** WireGuard VPN traffic on UDP port 51820.

### 3. Compute Services
- **AWS Lambda**: Serverless functions running in the private VPC. They are configured to securely communicate with the database layer via an RDS Proxy.
- **AWS Fargate**: Containerized applications running in the private VPC. These containers are configured to accept incoming HTTP traffic on port 3000, originating specifically from the Public VPC.

### 4. Database & Data Layer
- **Amazon RDS (Database)**: The main relational database resides in the private VPC. It is strictly isolated and does not accept direct application connections.
- **RDS Proxy**: Acts as a secure intermediary between the Lambda functions and the RDS database (port 3306). This helps manage and pool database connections efficiently.

### 5. Load Balancing
- **Application Load Balancer (ALB)**: Situated in the public VPC, it acts as the primary entry point for external users, accepting HTTP traffic on port 80 and routing it to the backend services.
 
### 6. AWS Service Endpoints (VPC Endpoints)
To maintain a high security posture and avoid routing internal traffic over the public internet, backend services (Lambda, Fargate) communicate with native AWS APIs via strictly controlled VPC Endpoints.

- **Interface Endpoints** (Restricted to port 443 from Lambda and Fargate SGs):
- **Secrets Manager**: For securely retrieving application secrets and database credentials.
- **ECR (API & Docker)**: For pulling container images securely to Fargate.
- **CloudWatch Monitoring**: For pushing custom metrics.
- **CloudWatch Logs**: For centralized application and system logging.

- **Gateway Endpoint**:
- **S3**: Attached directly to the private route table, ensuring secure, high-bandwidth access to object storage.

## Security Groups (Traffic Flow)

Network traffic is strictly controlled using the principle of least privilege through granular AWS Security Groups:

| Security Group | Purpose / Rules |
| :--- | :--- |
| **`alb-sg`** | Allows public inbound HTTP traffic (`0.0.0.0/0` on port 80). |
| **`vpn-sg`** | Allows public inbound SSH (port 22) and UDP VPN traffic (port 51820). |
| **`fargate-sg`** | Allows inbound application traffic on port 3000 **only** from the Public VPC CIDR block. |
| **`lambda-sg`** | Default egress rules for Lambda functions. |
| **`proxy-sg`** | Allows inbound database queries (port 3306) **only** from the Lambda Security Group. Egress is restricted to the Database Security Group. |
| **`db-sg`** | Accepts inbound database connections (port 3306) **exclusively** from the RDS Proxy Security Group. |
| **`vpc-endpoints-sg`** | Allows inbound HTTPS (port 443) traffic **strictly** from Lambda and Fargate Security Groups to communicate with AWS Services. |

## Getting Started

Since the environment uses an ECR to get the Grafana image, before being able to deploy it, the ECR repository and the Grafana image 
must be created manually. The Grafana image is created with the docker repository. The following steps are to properly create and upload the 
Grafana image to the ECR repository:

```bash
docker pull grafana/grafana:latest
aws ecr get-login-password --region "REGION" | docker login --username AWS --password-stdin "AWS_PROFILE_NUMBER".dkr.ecr."REGION".amazonaws.com
docker tag grafana/grafana:latest "AWS_PROFILE_NUMBER".dkr.ecr."REGION".amazonaws.com/"ECR_REPO_NAME":latest
docker push "AWS_PROFILE_NUMBER".dkr.ecr."REGION".amazonaws.com/"ECR_REPO_NAME":latest
```

Apart from the EC2 repository, for the VPN tunnel to work, EC2 key pair needs to be created. The name of the key must be **`dev-vpn-key`**, the key type should be **`RSA`** and the key file format must be **`.pem`**

To deploy this infrastructure, initialize Terraform and apply the configuration:

```bash
terraform init
terraform apply
```