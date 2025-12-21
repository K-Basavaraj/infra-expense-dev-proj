# Backend Application Infrastructure 
## Overview
This folder implements a production-grade backend deployment strategy using:

* Terraform (Infrastructure provisioning)
* Ansible (Application configuration – pull based)
* Shell scripting (Bootstrap)
* AMI + Launch Template + Auto Scaling Group
* Application Load Balancer (ALB)
* Rolling update (Zero downtime)

**⚠️ Important Note**
This backend runs in private subnets and is not accessible without VPN access.
VPN connection is mandatory to test or access this backend.
---
# Quick Navigation (Skip What You Already Know)
(#-Core AWS Concepts)
(#-Deployment Approaches)
(#-Why We Chose This Approach)
(#-High-Level Flow)
(#-Step-by-Step Implementation)
(#-Rolling Update Strategy)
(#-Terraform Special Concepts Used)
(#-Ansible & Shell Integration)
(#-Final Flow Summary)
(#-Conclusion)
---
## Core AWS Concepts

### What is an AMI (Amazon Machine Image)?
* An AMI is a pre-configured template/snapshot used to launch EC2 instances. 
It includes: Operating System, Installed software and packages, Application code, Configuration settings

**Why it matters:**
AMI ensures consistent and repeatable deployments.

👉 **In this project:**
* Each backend application version is baked into a separate AMI, so every deployment is immutable and predictable.
* Each backend version = one AMI.

### What is a Launch Template?
* A Launch Template defines how new EC2 instances should be created. 
It contains: AMI ID, Instance type, Security groups, Key pair and other instance settings.

**Why it matters:**
* Launch Templates act as the blueprint/input for Auto Scaling Groups.

👉 **In this project:**
* The Launch Template is used as input for the Auto Scaling Group.
* Any change (new AMI / backend version) creates a new Launch Template version.
* ASG uses the latest version to refresh instances during deployment.

### What is an Auto Scaling Group (ASG)?
An ASG Maintains desired number of instances are always running, automatically Replaces unhealthy instances, and Instances scale in or out based on traffic/load.

**Why it matters:**
ASG provides high availability, fault tolerance, and scalability.

👉 **In this project:**
ASG is responsible for managing backend EC2 instances and keeping the application highly available.

### What is an Auto Scaling Policy?
An Auto Scaling Policy tells to ASG, when and how scaling should happen.

**Policy used in this project:**
* Target CPU utilization = 70%
   * Scale out when CPU increases > 70%
   * Scale in when CPU decreases < 70%

**Why it matters:**
This ensures the system scales automatically based on real usage, not manual intervention.


### What is a Target Group?
A Target Group: Registers/Holds backend  EC2 instances, Performs health checks, Receives traffic from the Application Load Balancer (ALB). 
* 👉 ALB never communicates directly with EC2 instances — it always routes traffic through a Target Group.

**Why it matters:**
Target Groups enable health-based routing and zero-downtime deployments.
---