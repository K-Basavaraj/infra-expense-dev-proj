# CDN (CloudFront)
## 1. What is a CDN?
A Content Delivery Network (CDN) distributes content through global edge locations to reduce latency and improve performance.
* CloudFront improves performance, security, and scalability while reducing backend load.

## 2. Why CDN is used in this project
* Improve website performance.
* Reduce load on Web ALB & EC2.
* Cache static content.
* Enforce HTTPS.
* Restrict access by country.

## 3. CDN Position in Architecture
```
User → CloudFront → Web ALB → Frontend → Backend
```