# What is a Load Balancer?
A Load Balancer is a service that sits between clients and servers and distributes incoming traffic across multiple servers to ensure: High availability, Fault tolerance and Better performance.

Instead of users or applications directly hitting servers, they talk to the Load Balancer, and the Load Balancer decides where to send the request.

---
# Types of Load Balancers 

## Network Load Balancer (NLB)

* Works at Layer 4 (TCP/UDP)
* Routes traffic based on IP and port
* Very fast and handles millions of requests per second
* No application-level intelligence which is Does NOT understand HTTP/HTTPS content
* No host-based or path-based routing

#### Used when:
* Low latency is required  
* TCP/UDP traffic (databases, messaging, real-time apps)
----
# TCP vs UDP
## TCP (Transmission Control Protocol)
• Connection-oriented (connection is established first)
• Reliable – guarantees data delivery
• Maintains order of packets
• Slower compared to UDP due to checks and acknowledgements
#### Used when:
– Data accuracy is critical  
– Missing data is NOT acceptable  
#### Examples:
* HTTP / HTTPS  
* SSH  
* FTP  
* Database connections

## UDP (User Datagram Protocol)
• Connectionless (no handshake)
• Faster, but NOT reliable
• No guarantee of delivery or order
• Lower latency
#### Used when:
– Speed is more important than accuracy  
– Small data loss is acceptable  
#### Examples:
* DNS
* Video streaming  
* Online gaming  
* Voice calls (VoIP)  
---

## Application Load Balancer (ALB) 
Works at Layer 7 (HTTP/HTTPS)
Understands: URLs, Hostnames, Paths, Headers
Supports: Host-based routing, Path-based routing, Fixed responses, Redirects

#### Best suited for:
– Modern web applications  
– Microservices  
– APIs
For modern web applications and microservices, ALB is preferred.

---
### Why Application Load Balancer for Backend?

#### In this project:
* Backend services are HTTP-based
* Clean URLs are required
* Routing decisions depend on hostname
* So an Application Load Balancer is the correct choice.

# Application Load Balancer Request Flow 
To understand how traffic moves through an Application Load Balancer (ALB), think of it as a decision pipeline 
with four layers:
```
ALB → Listener → Rules → Target Group → Backend Servers
```
Each layer has a clear responsibility.

## Application Load Balancer (ALB) – Entry Point
The Application Load Balancer is the first component that receives requests.

### In this project:
The ALB is internal
It lives in private subnets
It is reachable only from:
Frontend servers
Bastion / VPN (based on Security Groups)

#### Example request:
```
 backend.app-dev.basavadevops81s.online
```
This request first reaches the Application Load Balancer.

### Listener – Port Listener
A listener defines:
* Which port the ALB listens on
* Which protocol it accepts
* What action to take next

#### In this project:
Listener:
Port: 80
Protocol: HTTP
So:
Any HTTP request on port 80
Is accepted by the listener
If no listener exists on a port, the ALB will reject the request.

### Rules – Decision Logic
After a request reaches the listener, the ALB evaluates listener rules.

Rules decide:
Where the request should go Based on conditions like:
* Hostname
* Path
* Headers

#### Example (future rule):
IF hostname = backend.app-dev.basavadevops81s.online
THEN forward to backend target group

Rules are checked top to bottom.
* First matching rule is applied.
* If no rule matches → default action is used. Default Action – Fixed Response 
(App ALB) uses a wildcard DNS record and a fixed response as the default action.
```
*.app-dev.basavadevops81s.online 
something.app-dev.basavadevops81s.online 
```
So the listener uses a default fixed response:
```
Hello, I am from Application ALB
```
This helps verify:

* ALB is working
* DNS is resolving correctly
* Listener is active

Example:
app-dev.basavadevops81s.online
→ App ALB
→ Fixed response

The ALB forwards traffic to only healthy targets in the target group.