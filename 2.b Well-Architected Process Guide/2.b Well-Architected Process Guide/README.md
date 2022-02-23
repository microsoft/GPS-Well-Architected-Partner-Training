# Well-Architected processes and tools for ISV and self-serve guide

> Work in progress

The Well-Architected Framework contains a set of processes and tools to help customers review and enhance their workloads on Azure. You can find a detailed explanation on how to use the framework in the [Well-Architected Workshop][waf-workshop].

This guide is intended to provide you with a step-by-step process to review the architecture of your own workload, and build a roadmap with the recommendations you will get after running the assessment.

## Prerequisites

### Select the workload

You should have already seen in the [Well-Architected Introduction][waf-introduction] and [Workshop][waf-workshop] that we are going to work over a specific workload.So the first step is to define which workload we are going to review and gather some basic information about it. You may already know everything about your workload, but take the time to document it so anyone can have this information in the same place.

| **Field** | **Description** |
| --- | --- |
| **Name** | The actual name for your workload|
| **Description** | A short description of your workload in three paragraphs:<br>* The business case it adresses<br>* The technology it is using<br>* The team and resources it needs |

### Define Scope

Doing a complete assessment of your workload can be a long process and takes a long time. So it is better to define a scope for your assessment to focus on the most important areas aligned with your current business needs.Select between one or three of the five-pillars of the Well-Architected Framework:

- [ ] Cost optimization
- [ ] Performance Efficiency
- [ ] Reliability
- [ ] Operational Excellence
- [ ] Security

Do not worry if you feel you cannot choose only three, the assessment will provide you with recommendations in other pillars as well, but it is better to focus on the ones that will have a greater impact in the short term.


[waf-introduction]: ../0. Well-Architected Introduction
[waf-workshop]: ../1.%20Well-Architected%20Workshop
