# Executive Summary: Enterprise Active Directory Security Architecture

## The Challenge: The Collapse of the Perimeter
* Traditional cybersecurity relied on the "Castle and Moat" model, which assumed that everything inside the internal network was inherently trustworthy.
* However, technological advancements have decentralized networks through cloud adoption, remote work, and mobile devices, effectively dissolving the traditional perimeter.
* Once attackers breach the initial defenses (e.g., via social engineering or malicious USBs), they frequently utilize "Living off the Land" (LotL) techniques.
* This technique involves using native, legitimate operating system tools, such as PowerShell or Command Prompt, to execute malicious commands and evade classic security solutions.
* Attackers then exploit legacy authentication architectures, extracting NTLM hashes from system memory to execute Pass-the-Hash (PtH) attacks and move laterally across the network.
* The ultimate goal of these intrusions often results in privilege escalation, ransomware deployment, and data extortion.

## The Solution: Identity as the Perimeter & Zero Trust
* Because organizations can no longer trust the network from which a user connects, the validation mechanism must shift to the Identity itself.
* The Zero Trust architecture operates on the fundamental principle of "never trust, always verify" and treats every access request as if it originates from a hostile network ("assume breach").
* To protect highly privileged identities from memory extraction attacks, the architecture implements the Microsoft Enterprise Access Model (Tiering Model).
* This model divides Active Directory resources into three isolated layers to prevent total domain compromise: Tier 0 (Domain Controllers/Admins), Tier 1 (Servers), and Tier 2 (Standard Users/Workstations).
* A fundamental rule of this model is the strict prohibition of credential overlap, preventing Tier 0 administrators from authenticating on vulnerable Tier 1 or Tier 2 machines.
* Access to network resources is dictated entirely by business function using Role-Based Access Control (RBAC), which effectively decouples the identity from the permission.

## The Implementation: Infrastructure as Code (IaC) & Hardening
* Building a complex Active Directory environment manually via graphical interfaces is prone to human error and difficult to replicate.
* To align with modern systems engineering, the entire infrastructure was implemented using Infrastructure as Code via PowerShell scripts, guaranteeing absolute repeatability.
* The automated provisioning engine ingests external user data, generates standardized names, and places accounts directly into the Tier 2 structure while adding them to corresponding security groups.
* Security is proactively strengthened (Hardening) using Group Policy Objects (GPO) to severely limit lateral movement and attacker visibility.
* To neutralize LotL techniques, a strict policy disables command-line interfaces, restricts PowerShell modules, and blocks access to the Registry Editor for standard Tier 2 users.

## Business Impact & Validation
* The automated provisioning process completely eliminates manual administrative intervention, reducing the risk of incorrect rights allocation to zero.
* At the file system level, NTFS permission inheritance is explicitly broken to adopt a strict "Deny by Default" posture.
* Practical testing validated that unauthorized users attempting to access cross-departmental data receive kernel-level "Access Denied" blocks, effectively preventing information theft and extortion.
