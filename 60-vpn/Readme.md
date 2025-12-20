# VPN (OpenVPN) – Secure Access Layer
📌 **Note**  
If you already understand Client–Server and Proxy concepts:
➡️ [Skip basics and go to VPN implementation](#-vpn-openvpn--project-specific-implementation)
--
### What is a Client?
A client is a device or software application that requests services or resources from another system.
Examples of clients: Web browsers (Chrome, Edge, Firefox, Opera), Mobile apps, Computers, laptops, smartphones
Command-line tools like curl or wget.
* Simple example: When you open a website in Chrome, Chrome is the client that requests a web page.

### What is a Server?
A server is a powerful system that provides services to clients. Servers listen for requests and respond accordingly.
* Common types of servers:
- Web Server: Serves web pages (HTML, CSS, JS)
- Application Server: Runs application logic (APIs, backend services)
- Database Server: Stores and manages data
- File Server: Stores and shares files
- Email Server: Handles email communication

### Simple Client–Server Example (Easy Analogy)
Imagine a library:
* You → Client
* Librarian → Server
* Book request → Client request
* Book provided → Server response
You ask for a book (request), and the librarian gives it to you (response).

### Why Client–Server Alone Is Not Enough
In real-world applications:
* Many clients access the same server
* Servers should not be exposed directly to everyone
Security, scalability, and control are required That’s why proxies are introduced.
---
## What is a Proxy?
A proxy is someone or somthing  that has the authority to act or to do  on behalf of another person.
A proxy sits between a client and a server and controls traffic.
* There are two important types:
# Forward proxy?
A forward proxy is a client-side proxy that acts as an intermediary between the client and the internet, meaning only the client is aware of its existence.
#### Here are the key advantages:
* **Access to Restricted Content**: Allows users to bypass geographic restrictions and access content that may be blocked in their region.
* **Geo-Location Change**: Enables users to appear as if they are browsing from a different location, which can be useful for accessing region-specific services.
* **Hiding client identity**: Masks the client’s IP address, enhancing privacy and preventing tracking by websites and other entities.
* **Traffic Monitoring**: Organizations can monitor and log internet activity, which helps in analyzing usage patterns and enforcing policies.
* **Secure Connections**: Can provide an additional layer of security by managing connections and helping to protect against certain online threats.
* **Content Access Restriction**: Allows organizations to restrict access to specific websites or content, ensuring compliance with internal policies.
* **Caching Capabilities**: Stores frequently accessed content, improving load times and reducing bandwidth usage by serving cached pages instead of fetching them again from the internet.

### Example in this project:
```
Laptop → VPN → AWS VPC → Internal Resources
```
Here, the VPN acts as a forward proxy. 
A VPN (Virtual Private Network) allows a client to: 
- Securely connect to a private network
- Appear as if it is inside that network
- Access internal services safely
* After VPN connection:
- Laptop becomes part of AWS VPC
- Internal Load Balancers and servers are reachable

# Reverse Proxy?
* A reverse proxy is a server-side proxy, sits between client devices and a backend server, handling requests from clients on behalf of the backend servers. Only the servers are aware of the reverse-proxy. 

* so, When a client makes a request, the reverse proxy forwards it to the appropriate backend server, retrieves the response from the backend-server, and then sends that response back to the client.

#### Here are the key advantages:
* **Security**:  A reverse proxy adds a layer of security between clients and backend servers, helping to protect the servers from direct exposure to the internet and reducing various attacks..
* **Load Balancing**: It efficiently distributes incoming traffic across multiple backend servers, ensuring no single server becomes overloded and enhancing overall performance.					
* **SSL Termination**: The reverse proxy can handle SSL encryption and decryption, offloading this resource-intensive process from the backend servers, which improves their performance and simplifies certificate management.

### Example in this project:
```
Client → Load Balancer (ALB) → Backend Server
```
Here, the Application Load Balancer is a reverse proxy.

#### example2: 
* In an e-commerce scenario, when a customer visits the website and adds items to their cart, their request first goes to a reverse proxy server instead of directly to the backend servers. 
* The reverse proxy evaluates the load on the backend servers and forwards the request to the least busy one.
* After the backend server processes the request and retrieves the necessary information, it sends the response back to the reverse proxy, which then delivers the updated cart details to the customer. 
* This arrangement improves performance, ensures efficient load distribution, and adds an extra layer of security during high traffic periods.
---

# 🔐 VPN (OpenVPN) – Project-Specific Implementation
The above concepts (Client–Server, Forward Proxy, Reverse Proxy) explain why VPN is needed.
This section explains how VPN is implemented in this project and why each step is required.

## Why VPN is Used in This Project
* Backend Application Load Balancer is internal.
* Backend and database servers are in private subnets.
* These resources cannot be accessed directly from a laptop browser.

#### Without VPN:
* Access requires logging into Bastion.
* Testing must be done using curl.
* Not user-friendly for daily work.

#### With VPN:
* Laptop becomes part of AWS VPC.
* nternal Load Balancers and servers are accessible from browser.
* No need to SSH into Bastion every time.
VPN provides secure, direct access for developers and admins

#### 🖥️ VPN AMI Used and Why
AMI Chosen: OpenVPN Access Server – Community Image.
* OpenVPN is already installed and configured.
* Provides: Admin UI, Client UI, Certificate-based VPN, Minimal manual setup, Ideal for learning and practice.
* This avoids: Installing VPN software manually, Complex OpenVPN configuration.

---
### 🔑 Key Pair Is Mandatory
* This OpenVPN AMI is public and Password-based SSH login is disabled, AWS requires key-based authentication.
So we must: Generate a public/private key pair.

* SSH Access:
```
ssh -i ~/.ssh/openvpn openvpnas@<VPN_PUBLIC_IP>
```
This access is used only for: Initial verification and Troubleshooting.

#### 🔓 VPN Ports and Their Purpose

The VPN security group allows the following ports & its Purpose: 
* 22  SSH access to VPN server.
* 943  OpenVPN Admin UI.
* 443  OpenVPN Client UI / HTTPS.
* 1194 VPN tunnel traffic.

* These ports are already defined in the 20-sg module and reused here.
Without these ports, VPN will not function.
--- 

⚙️ OpenVPN Admin UI Configuration (Important)

Admin UI is accessed via:
```
https://<VPN_PUBLIC_IP>:943/admin
```
After first login, the following settings were configured.

### VPN Settings – Why We Enable Them
#### Should client Internet traffic be routed through the VPN? 

* **YES** Why:
* Routes laptop traffic through AWS VPC
* Changes source IP to AWS region
* Enables access to internal resources
* This enables forward proxy behavior.

#### Should client be allowed to access network services on the VPN gateway IP? 
* **YES** Why:
* Allows clients to access internal services
* Required for proper VPC connectivity

### DNS Settings – Why These Are Important
#### Have clients use specific DNS servers as the access server host? 
* **NO/Disable** Why:
* Prevents dependency on VPN server DNS
* Avoids DNS resolution issues

#### have clients use specific DNS servers? **YES**
* Configured DNS:
Primary: 8.8.8.8
Secondary: 8.8.4.4

Why:
* Prevents DNS leaks
* Ensures domain resolution works correctly
* Allows resolving:
    - Public domains
    - Internal application domains
After saving these settings, VPN service applies the configuration.
---
#### Connecting to VPN (High-Level)
* Install OpenVPN Connect client on laptop
* Use Client UI URL
* Login with VPN credentials
* Click Connect
* After connection:
    - Laptop IP changes to AWS region
    - Laptop behaves as if inside AWS VPC
---
Now you can access: Without using Bastion.
```
*.app-dev.basavadevops81s.online --> forward request to fixed response
backend.app-dev.basavadevops81s.online --> forward request to taraget group
```
---
### Conclusion:
* VPN is used for daily secure access
* Bastion is used for emergency or deep troubleshooting
Both are required in real-world architectures.