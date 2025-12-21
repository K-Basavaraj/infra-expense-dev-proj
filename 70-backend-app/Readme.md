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
* ASG doesn’t know when to scale on its own; this policy tells it to scale, so it uses Auto Scaling Policy.

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
## Step-by-Step Implementation
* **Step 1**: Create Temporary Backend EC2, Created only for building the AMI, Not exposed to users, Located in private subnet.
* **Step 2**: Configure Backend Using Ansible (Pull Based), Terraform copies backend.sh, Script installs Ansible, Uses ansible-pull to fetch playbooks
👉 Ansible roles repo used:
```
🔗 https://github.com/K-Basavaraj/expense-anisble-terraform-proj
```
* **Step 3**: Stop the Instance: Why because,  it Ensure filesystem consistency, Avoid partial configurations in AMI.
* **Step 4**: Take the AMI, Captures fully configured backend, This AMI becomes the source of truth.
* **Step 5**: Delete Temporary Instance, no longer needed to Saves cost and Prevents misuse.
* **Step 6**: Create Target Group, Backend listens on port 8080, Health check path /health, Only healthy instances receive traffic.
* **Step 7**: Create Launch Template, Uses the new AMI, Any change → new version
* **Step 8**: Create Auto Scaling Group, Minimum instances always running, Automatically replaces unhealthy instances and Connected to target group
---
## Rolling Update Strategy
This project uses a Rolling Update strategy to deploy new backend versions without any downtime.
When a new backend version is deployed (via a new AMI and Launch Template version), the Auto Scaling Group updates instances gradually, not all at once.
* Example: 4 instances are running, when New version deployed as follows: 
  * Launch 1 new instance using the updated Launch Template.
  * Wait until the instance passes Target Group health checks.
  * Terminate 1 old instance.
  * Repeat the process until all instances are replaced.

* Key configuration:
Minimum healthy instances: 50%, and ensures at least 2 instances are always serving traffic.
  * Rolling update trigger: Launch Template version change(or)Triggered by Launch Template changes.
  * Health validation: ALB Target Group health checks.

* **Why This Strategy Is Used**
    * Ensures zero downtime during deployments.
    * Prevents traffic drops and service interruptions.
    * Easy to manage using native Auto Scaling Group behavior.
---
## ⚙️ Terraform Special Concepts Used
#### 1) null_resource: is used when Terraform needs to trigger an action like running a script, but there is no actual infrastructure resource to manage.
**What it is used for in this project:**
 * Run shell scripts after EC2 instance creation.
 * Trigger provisioning logic when backend instances are ready.
 * Perform temporary or one-time operational tasks.
**Why it is used:**
  * Allows execution of actions that are outside Terraform’s declarative model.
  * Helps coordinate deployment steps that depend on infrastructure readiness.
Note: null_resource is used carefully and minimally, as it is not ideal for long-term state management.

#### 2) Provisioners: used to configure instances after they are created.
Terraform best practice is to avoid heavy configuration in provisioners, but they are acceptable for bootstrapping and integration tasks.
    * file – Copy backend.sh to EC2.
    * remote-exec – Executes the backend setup script on the EC2 instance.
    * local-exec – Runs AWS CLI commands locally (for orchestration or integration steps).
--- 
## Ansible & Shell Integration
This project uses a combination of Shell scripting and Ansible (pull-based) to bootstrap and configure backend instances.
Shell scripts purpose is to run immediately on a fresh instance and require no dependencies, making them ideal for initial setup.
#### 1) **Why Shell Script?**
Shell scripting is used for lightweight bootstrapping tasks.
* Responsibilities:
 * Install required system packages
 * Install Ansible on the instance
 * Trigger the Ansible pull process

#### 2) **Why Ansible Pull?**
Ansible pull allows each instance to configure itself by pulling configuration from a Git repository.
* Reasons for choosing Ansible Pull:
 * No need for a central Ansible control server
 * Each EC2 instance is self-sufficient
 * Scales naturally with Auto Scaling Groups
 * Well-suited for AMI-based deployments
* This approach works seamlessly when instances are frequently created and destroyed by ASG.

## Flow:
```
Terraform
   ↓
Shell Script (Bootstrap)
   ↓
Ansible Pull
   ↓
Backend Application Configured
```
---
## Final Flow Summary
```
Route53
  ↓
Application Load Balancer
  ↓
Listener
  ↓
Rule (host-based)
  ↓
Target Group
  ↓
Health Check
  ↓
Auto Scaling Group Instance
```
## Conclusion
**This backend setup demonstrates:**
  * Immutable infrastructure
  * Zero downtime deployments
  * Safe scaling
  * Clean separation of concerns
* Terraform provisions infrastructure
* Ansible configures once
* AMI captures state
* ASG scales safely
This is production-grade backend architecture.