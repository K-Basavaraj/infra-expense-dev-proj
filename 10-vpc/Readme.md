# About Virtual private cloud(VPC) in AWS? 
A VPC is a logically isolated network in AWS Cloud. where you launch your aws resources (EC2, RDS, ALB, etc.) in a virtual network that you define. 

- A VPC helps us to control your network resources and increase security by this way we cvan secure and monitor connections.
screen traffic and restrict instance access. 
- aws VPC gives you full control over your resource placement, connectivity and secuirty. 
- spend less time setting up, managing, and validating your virtual network when compared to On-Premises netwoirk managemnt. 
---
# What are Subnets? 
A subnet is a smaller network inside a VPC. allowing to divide the VPC into smaller, manageable sections. 
A subnet is a range of ip adresses in the vpc. By this way Improve security and Support high availability.

subnets are used to organize your rersources and can be publicly or privately accessible. 
- A Private subnets are designed to isolate the resource that should not be directly exposed to public/internet. 
commenly used to conatin resources like a Database storing customer or transactional information. 
Used for: Backend application servers, and Internal services.

- A public subnet are designed to provide direct internet access to resource placed inside them to allow access they are connhected withan internet gateway.                                                                                          commonly Used for: Frontend servers(customer-facing website), Load Balancers, NAT Gateway, Bastion hosts etc;

- Database Subnet is a special type of private subnet designed for databases.                                                     Used for: RDS or Database instances                                                                                               Databases are stateful and must be highly isolated for security. These subnets are grouped using a DB Subnet Group.
---
# What is a DB Subnet Group?
A DB Subnet Group is a collection of database subnets across multiple Availability Zones.
Used by: RDS services in this project
Purpose:
- High availability
- Fault tolerance
- Controlled database placement
---
# What is an Internet Gateway (IGW)? 
An Internet Gateway allows communication between the VPC and the internet. It is required for Public subnets, Inbound and outbound internet traffic Without IGW: Your VPC is completely isolated from the internet. 
To allow public traffic from the internet to access your vpc, aattach internet gateway to the vpc. 

---
# What is an Elastic IP (EIP)?
An Elastic IP is a static public IPv4 address provided by AWS.
Used for: NAT Gateway, Fixed outbound internet access
EIP ensures the public IP does not change.

---
# What is a NAT Gateway?
A NAT Gateway is a network adress translation service to allows private subnets resources to access the 
internet which is outside vpc without exposing them to inbound traffic.
(or)
A NAT (Network Address Translation) Gateway allows instances in private subnets to initiate outbound connections while blocking inbound connections that are not requested.

## When you create a NAT Gateway in AWS, you must choose a connectivity type:
- 1) (default)A public NAT Gateway: allows private subnet instances to access the Internet, but prevents the Internet from directly accessing those instances.
### How it works
* NAT Gateway Created inside a public subnet
* Must be associated with an Elastic IP (EIP)
* Uses the Internet Gateway (IGW) of the VPC for outbound Internet access
### Traffic flow
```
Private EC2 → Public NAT Gateway → Internet Gateway → Internet
```
### Key points
* Instances can send traffic out (updates, downloads, APIs) but cannot receive inbound connections that they did not request.
* NAT Gateway itself is not directly accessible from the Internet. advanced use a public NAT Gateway to connect Other VPCs, On-premises networks In this case, traffic is routed via, Transit Gateway (TGW) or Virtual Private Gateway (VGW) instead of the Internet Gateway.

- 2) Private NAT Gateway: A private NAT Gateway allows private subnet instances to connect to other VPCs or on-premises networks, without Internet access.
### How it works
NAT Gateway created inside a private subnet, No Elastic IP
Used only for internal/private connectivity

### Traffic flow
```
Private EC2 → Private NAT Gateway → TGW / VGW → Other VPC / On-prem
```
### Key points
Instances can send traffic outbound but cannot receive inbound connections that they did not request.
Outbound traffic does not always mean Internet traffic
Internet access is not supported

⚠️ Even if an Internet Gateway is attached to the VPC, and You try to route traffic from Private NAT Gateway to IGW
AWS drops the traffic can be Internet, Other VPCs or On-premises networks

because Private NAT Gateway is not designed for Internet traffic.

--- 