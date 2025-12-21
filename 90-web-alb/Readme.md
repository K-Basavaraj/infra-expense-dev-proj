# Web Application Load Balancer (90-web-alb)
## Overview
This folder provisions the Frontend (Web) Application Load Balancer using Terraform.
The Web ALB acts as the public entry point for end users and securely forwards traffic to frontend application servers.
This ALB:
 * Is internet-facing
 * Supports HTTP (80) and HTTPS (443)
 * Terminates TLS at the load balancer
 * Routes traffic to frontend target groups (configured later)
 ---
## What is an Application Load Balancer?
An Application Load Balancer (ALB) is a Layer 7 (HTTP/HTTPS) load balancer that:
Acts as a reverse proxy, Distributes traffic based on rules (host/path), Performs health checks and Handles SSL/TLS termination

**In this project, the ALB ensures:**
High availability
Secure access
Clean traffic routing

**Why Web ALB is Required**
* End users should never access EC2 instances directly.
* The Web ALB is required to:
 * Accept traffic from the internet
 * Terminate HTTPS securely
 * Forward traffic only to healthy frontend servers
 * Protect backend infrastructure from direct exposure

---
## High-Level Traffic Flow
* User Browser
   → Route53
   → Web Application Load Balancer
   → Listener (HTTP/HTTPS)
   → Listener Rules (in frontend module)
   → Frontend Target Group
   → Frontend EC2 Instances
---
## What This Folder Creates?
* An internet-facing Application Load Balancer
* HTTP listener on port 80
* HTTPS listener on port 443
* TLS certificate attachment (via ACM)
* Route53 alias record for public domain
* SSM parameter for Web ALB listener ARN
* Note: Target groups and listener rules are created in the 100-frontend folder.
---
## DNS & HTTPS Configuration
* DNS (Route53) Public domain:
```
expense-dev.basavadevops81s.online
```
Mapped to Web ALB using Alias record, and No public IP exposure. 

* HTTPS
    * TLS certificate is managed in AWS ACM
    * Certificate ARN is fetched from SSM Parameter Store
    * SSL termination happens at the ALB
---
## Conclusion
The Web ALB is the public gateway of the application.
It securely handles user traffic, terminates HTTPS, and forwards requests to frontend servers in a controlled and scalable way.

* This design ensures:
    * Security
    * Scalability
    * Clean separation between users and infrastructure