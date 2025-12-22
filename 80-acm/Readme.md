## What is ACM?
* AWS Certificate Manager (ACM) is a managed AWS service used to create, manage, and renew SSL/TLS certificates.
These certificates are required to enable HTTPS (secure communication) for:
  * Application Load Balancers (ALB)
  * CloudFront
  * API Gateways
ACM removes the need to:
  * Buy certificates manually
  * Install certificates on servers
  * Renew certificates periodically
* NOte: AWS automatically renews ACM certificates.

## Why ACM is required in this project
* The Web Application Load Balancer uses HTTPS (port 443).
* HTTPS cannot work without a valid SSL certificate.
* Multiple subdomains are used so, Instead of creating multiple certificates for multiuple subdomains, used one wildcard certificate.

## What is a Wildcard Certificate?
A wildcard certificate secures:
```
*.basavedevops81s.online
```
This single certificate covers:
 * Any current subdomain.
 * Any future subdomain without changes.
* Cost-effective
* Easy to manage
* Best practice in real projects
---
## What This Folder (80-ACM) Creates
This Terraform folder performs four important steps:
* Request an SSL certificate from ACM.
* Validate domain ownership using DNS.
* Wait until the certificate is issued.
* Store the certificate ARN in SSM Parameter Store.
This makes the certificate reusable by other infrastructure components.
---
## What is aws_acm_certificate_validation?
aws_acm_certificate_validation is a Terraform resource that:
* Waits for DNS records to be created.
* Confirms ownership with AWS.
* Ensures the certificate reaches ISSUED state.

Without this resource:
* Terraform may continue But the certificate may remain in PENDING_VALIDATION and Load balancers will fail to attach HTTPS listeners.
---

## How This Fits into the Project Architecture
```
80-ACM
   ↓
SSM Parameter Store
   ↓
90-Web-ALB (HTTPS Listener)
   ↓
100-Frontend
```
 * ACM handles security (HTTPS).
 * Web ALB consumes the certificate.
 * Frontend traffic becomes encrypted.
---
### summary
 * ACM is used to create and manage SSL certificates.
 * DNS validation proves domain ownership automatically.
 * aws_acm_certificate_validation ensures Terraform waits correctly.
 * A wildcard certificate secures all subdomains.
 * Certificate ARN is shared safely via SSM.
 * This enables secure HTTPS access for Web ALB.