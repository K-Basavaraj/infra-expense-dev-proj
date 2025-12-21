# Backend Application Infrastructure 
## Overview
This folder implements a production-grade backend deployment strategy using:

* Terraform (Infrastructure provisioning)
* Ansible (Application configuration – pull based)
* Shell scripting 
* AMI + Launch Template + Auto Scaling Group
* Application Load Balancer (ALB)
* Rolling update (Zero downtime)

⚠️ **Important Note**
* This backend runs in private subnets and is not accessible without VPN access.
* VPN connection is mandatory to test or access this backend.
---
## Quick Navigation (Skip What You Already Know)
- [Core AWS Concepts](#core-aws-concepts)
- [Deployment Approaches](#deployment-approaches)
- [High-Level Flow](#high-level-flow)
- [Step-by-Step Implementation](#step-by-step-implementation)
- [Rolling Update Strategy](#rolling-update-strategy)
- [Terraform Special Concepts Used](#terraform-special-concepts-used)
- [Ansible & Shell Integration](#ansible--shell-integration)
- [Final Flow Summary](#final-flow-summary)
- [Conclusion](#conclusion)
---
## Core AWS Concepts

### 1) What is an AMI (Amazon Machine Image)?
* An AMI is a pre-configured template/snapshot used to launch EC2 instances. 
It includes: Operating System, Installed software and packages, Application code, Configuration settings.

**Why it matters:**
AMI ensures consistent and repeatable deployments.

👉 **In this project:**
* Each backend application version is baked into a separate AMI, so every deployment is immutable and predictable.
* Each backend version = one AMI.

### 2) What is a Launch Template?
* A Launch Template defines how new EC2 instances should be created. 
It contains: AMI ID, Instance type, Security groups, Key pair and other instance settings.

**Why it matters:**
* Launch Templates act as the blueprint/input for Auto Scaling Groups.

👉 **In this project:**
* The Launch Template is used as input for the Auto Scaling Group.
* Any change (new AMI / backend version) creates a new Launch Template version.
* ASG uses the latest version to refresh instances during deployment.

### 3) What is an Auto Scaling Group (ASG)?
An ASG Maintains desired number of instances are always running, automatically Replaces unhealthy instances, and Instances scale in or out based on traffic/load.

**Why it matters:**
ASG provides high availability, fault tolerance, and scalability.

👉 **In this project:**
ASG is responsible for managing backend EC2 instances and keeping the application highly available.

### 4) What is an Auto Scaling Policy?
An Auto Scaling Policy tells to ASG, when and how scaling should happen.

**Policy used in this project:**
* Target CPU utilization = 70%
   * Scale out when CPU increases > 70%
   * Scale in when CPU decreases < 70%

**Why it matters:**
This ensures the system scales automatically based on real usage, not manual intervention.


### 5) What is a Target Group?
A Target Group: Registers/Holds backend  EC2 instances, Performs health checks, Receives traffic from the Application Load Balancer (ALB). 
👉 ALB never communicates directly with EC2 instances — it always routes traffic through a Target Group.

**Why it matters:**
* Target Groups enable health-based routing and zero-downtime deployments.
---
## Deployment Approaches
* **👉 Approach 1**: Direct Deployment on Running Servers.
    * Create EC2 instances
    * Run Ansible on live servers
    * Stop service → update → restart
* Drawbacks:
    * Downtime
    * Risky updates
    * Slow scaling

* **👉 Approach 2**: Image-Based Deployment (Used Here)
    * Configure once
    * Create AMI
    * Scale using copies of AMI
    * No changes on live servers
* **why we Chose This Approach 2 is, it provides:**
    * Zero downtime deployments
    * Safe rolling updates
    * Fast auto scaling
    * Immutable infrastructure
    * Production-ready design
* **Golden rule**:
Never update running production servers. Always update images(AMI).
---
## High-Level Flow
```
Terraform
  ↓
Temporary Backend EC2
  ↓
Shell Script
  ↓
Ansible Pull (Configure Backend)
  ↓
Stop Instance
  ↓
Create AMI
  ↓
Delete Builder Instance
  ↓
Launch Template
  ↓
Auto Scaling Group
  ↓
Target Group
  ↓
ALB Listener Rule
```
---