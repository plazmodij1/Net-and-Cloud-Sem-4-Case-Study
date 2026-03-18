# Network and Resource IP Mapping

This document outlines the IP addressing scheme, subnets, and resource placement based on the Terraform definitions for the `dev` environment (`eu-central-1`).

## 1. Virtual Private Clouds (VPCs) & Subnets

| Network Component | CIDR Block | Availability Zone | Name / Tag | Routing / Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Public VPC** | `10.1.0.0/16` | | `dev-vpc-pub` | External-facing entry points |
| ├── Public Subnet (`dmz-1`) | `10.1.1.0/24` | `eu-central-1a` | `dmz-1-subnet` | DMZ for Public ALB |
| └── Public Subnet (`dmz-2`) | `10.1.2.0/24` | `eu-central-1b` | `dmz-2-subnet` | DMZ for Public ALB (HA) |
| └── VPN Subnet (`vpn`) | `10.1.3.0/24` | `eu-central-1a` | `vpn-subnet` | Dedicated subnet for VPN |
| **Private VPC** | `10.0.0.0/16` | | `dev-vpc-priv` | Isolated Backend |
| ├── App Subnet (`app`) | `10.0.4.0/24` | `eu-central-1a` | `app-subnet` | Compute layer (Lambda, Fargate) |
| ├── Data Subnet (`data-1`) | `10.0.1.0/24` | `eu-central-1a` | `data-1-subnet` | Database layer |
| └── Data Subnet (`data-2`) | `10.0.2.0/24` | `eu-central-1b` | `data-2-subnet` | Database layer (HA) |

## 2. Resource Mapping

This table maps the individual resources to their assigned subnets based on `main.tf`.

| Component | Location (Subnet Name) | CIDR Range | Security Group | Port / Protocol |
| :--- | :--- | :--- | :--- | :--- |
| **Application Load Balancer (ALB)** | `dmz-1`, `dmz-2` | `10.1.1.0/24`, `10.1.2.0/24` | `alb-sg` | `0.0.0.0/0` -> 80 (HTTP) |
| **VPN Server (EC2)** | `vpn` | `10.1.3.0/24` | `vpn-sg` | `0.0.0.0/0` -> 22 (TCP), 51820 (UDP) |
| **AWS Lambda** | `app` | `10.0.3.0/24` | `lambda-sg` | N/A (Event-driven, egress) |
| **AWS Fargate** *(per README)* | `app` (Implied) | `10.0.3.0/24` | `fargate-sg` | `10.1.0.0/16` -> 3000 (HTTP) |
| **RDS Proxy** | Private Subnets (`app`, `data-1`, `data-2`) | `10.0.1.0/24`, `10.0.2.0/24`, `10.0.3.0/24` | `proxy-sg` | `lambda-sg` -> 3306 (TCP) |
| **Amazon RDS (Aurora Cluster)** | `data-1`, `data-2` | `10.0.1.0/24`, `10.0.2.0/24` | `db-sg` | `proxy-sg` -> 3306 (TCP) |
| **VPC Interface Endpoints** | Private Subnets | Multiple `10.0.x.x` | `vpc-endpoints-sg` | SGs -> 443 (HTTPS) |

