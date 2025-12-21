# Frontend Application Infrastructure (100-frontend)
This folder provisions frontend infrastructure using Terraform, following the same AMI-based and Auto Scaling approach used for the backend.
## Reference: 70-backend-app
The frontend follows the same deployment pattern as 70-backend-app including AMI creation, launch templates, Auto Scaling Groups, and rolling updates.
Only frontend-specific differences are explained here to avoid duplication.
---
## Common Deployment Flow (Same as Backend)
* Temporary EC2 creation
* Configuration using Ansible (pull-based)
* Stop instance and create AMI
* Delete temporary instance
* Launch Template creation
* Auto Scaling Group with rolling updates
* CPU-based Auto Scaling policy
- Detailed explanation is available in 70-backend-app/README.md.
---
## Frontend-Specific Differences
### Subnet Placement: 
Frontend instances are launched in public subnets because they serve user-facing traffic via the Web ALB.
### Load Balancer: 
Frontend uses an internet-facing Application Load Balancer (Web ALB), unlike backend which uses an internal ALB.
### DNS and Routing
Requests to expense-dev.basavadevops81s.online are routed via Route53 → Web ALB → Target Group → Frontend ASG.
## Configuration Using Ansible
Frontend configuration is done using ansible-pull, similar to backend. Only the component name changes to frontend.
## Access Model
* Frontend is accessible only through the Web ALB.
* Direct SSH access is restricted and allowed only via VPN or Bastion.
---
## Conclusion
Frontend infrastructure reuses the same backend deployment strategy, ensuring consistency, scalability, and zero-downtime deployments with minimal duplication.