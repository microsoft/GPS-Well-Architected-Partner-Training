# Well-Architected 1 day lab

Welcome to the Well-Architected lab. This is a 1-day hands-on experience where you will be given a set of challenges
to practice the skills you learnt in the [Well-Architected Workshop](../1.%20Well-Architected%20Workshop).

In this lab you have to review the architecture of the Contoso Inc. Insurance company and provide a roadmap of recommendations
based on the Well-Architected principles.

## Agenda

Title | | Time
---|-:|---
The Well-Architected Opportunity for Partners || 15 min
Well-Architected Framework standardized process || 20 min
Break || 15 min
Group formation || 10 min
Case Study & Lab rest of the day |
Build your case |<table><tr><td>Review the customer case study</td><td>20 min</td></tr><tr><td>Plan for information collection</td><td>15 min</td></tr><tr><td>Cost optimization</td><td>45 min</td></tr><tr><td>Security</td><td>30 min</td></tr><tr><td>Reliability</td><td>60-90 min</td></tr><tr><td>Performance & Efficiency</td><td>45 min</td></tr><tr><td>Operational Excellence</td><td>30 min</td></tr></table> | ~4h    
Break || 45 min    
Teams presentation || 1h
Wrap up || 30 min
&nbsp;| Total: | **~6 h**

## Case Study

Contoso Inc., is an Insurance Company headquartered in Madrid, provides insurance solutions across 
Europe.
* **Mobile agents** located across the continent visit claimants to verify their claims and upload 
information using the Claims Application.
* Headquarters is in Madrid, Spain with various **branch locations**.
* Contoso IT group is a classic shop, mainly focused on infrastructure, **little automation** in operations. 
They use **legacy tools** for monitoring, governance, security and deployments.
* The **AppDev department’s skill set is dated**, predominantly focused on client/server development.
* The organization has an **Internet-based claims application** they recently deployed into Azure.
* The current design relies on a single SQL Server VM and a single AD VM. Web servers use a loadbalancer with TCP probe.
Branch offices are connected to Azure using Site-to-Site VPNs with on-site RRAS server. 
* Customers have reported **reliability issues** with the claims application. Failures were correlated to 
**service health issues with the SQL VM**.
* **Network connectivity** issues between the branch offices and the corporate office have occurred 
intermittently. Every time there is a failure in connectivity, IT team needs to travel to the branch office 
to troubleshoot on site.
* Disk storage has a heightened level of attention due to a critical server running out of disk space, 
highlighting gaps in proactive monitoring.
* Recent stability issues with the claims application prompted Contoso to perform a business impact 
analysis of the application.
* The result is an executive mandate **to achieve an SLA of at least 99.95%** for the claims application, 
with RTO of 4 hours and RPO of 6 hours, plus backup of all critical VMs and data
* The App Dev team is working on a **next-generation PaaS-based implementation** of the claims 
application. This is based on a Web App and Azure SQL Database.
* The need to achieve a similar level of resilience as the IaaS-based version, otherwise the business will 
not agree to migrate to PaaS.
* They need to improve in the application’s time to market as competition in the industry is fierce, **they 
need to implement automation** not only for their infrastructure provisioning but also for code 
deployment. They only have a pipeline for production code deployment
* As they plan on to moving to PaaS they need to **modernize their day-2 operational toolset**. 
* Security is a big concern as their deployment is internet facing and distributed. They need to **design 
their system securely** both in the cloud and branch offices. 
* The insurance industry is subject to regulatory standards that they need to align to and provide the 
mechanisms to **enforce compliance guidelines** as well as provide auditing information when 
requested. 
* Cost is a concern; they need to **optimize their current spending** with the IaaS design before 
planning for the next-gen PaaS deployment

### Customer Architecture

Currently have a single domain controller deployed in West Europe. Connectivity is enabled with a site-to-site VPN 
gateway.

![General architecture](support%20materials/arch1.png "There are two VPN tunnels to connect to Azure, one with headquarters and another one with the Branch office  ")

The claims application has this characteristics:
* Web servers deployed into an availability 
set
* SQL Server backend
(single VM)
* GRS Storage account for object storage
* Azure Bastion is deployed to manage the 
VM access.
* West Europe

![Claims application](support%20materials/arch2.png "The claims application is deployed in West Europe, with a single VM running a single SQL Server. ")

### Additional facts

* Development Environment uses the same size VMs and settings as Production. 
* AppDev team only access the environment 9:00-17:00 Monday through Friday. 
* All services are deployed in pay-as-you-go mode.
* Platform doesn’t use any WAF but NSG are configured. Claims Apps has not been configured SSL, yet.
* There is no up/down autoscaling set up.
* Any new version of the application is deployed manually. For monitoring they use an agent-based 3rd
party tool for the infrastructure metrics, there is no APM. No security or governance solution implemented. 
They use Azure Backup. 
* There is a mismatch of the expected consumption for the deployed resources and what they are being 
charged. They do not know where those charges may be coming from.

### Customer concerns and objections

Facts:
* After merging with another company, the customer is struggling to provide a good service from their claims app to their mobile agents.
* They need to provide redundancy and resiliency to deliver 99.95% SLA or greater
* Improve the reliability of the VPN
* Guarantee that BCDR and backup solutions are secure and cost effective
* Improve time to market of this app, it is a very competitive scenario and they need to automate deployments and processes
* They started to look into PaaS services but they fear they will be expensive and may not provide the required SLA
* After the merge, they have some disconnected infraestructure and teams, an legacy operational tooling that work in silos
* Need to improve internal structure for cloud operations
* Security and compliance are a big concern, highly regulated industry
* Claims app is exposed to the internet and they need to ensure it is secure

## Well-Architected Review

Here starts the exercise you have to do to review the architecture of the Contoso Inc. Insurance company claims application.

### 1 - Review the customer case study

### 2 – Plan for Information Collection

### 3 – Cost Optimization

### 4 – Security

### 5 – Reliability

### 6 – Performance Efficiency

### 7 – Operational Excellence

### 8 – Create a plan


## Ask The CTO Bot

If you need further information about how the company is using Azure you can ask questions to the CTO Bot:

* Teams: https://aka.ms/CTOBotES
* Telegram: https://telegram.me/contoso_insurance_cto_bot
* Web: https://aka.ms/CTOBotESWeb