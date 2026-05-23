# Security Architecture & Network Topology

This document visualizes the core architectural concepts implemented in the **AllSafeCorp** Zero Trust lab environment. The diagrams below illustrate the network boundaries, the Active Directory structural hierarchy, and the cryptographic isolation applied to file shares.

---

## 1. Dual-Homed Network Topology
To prevent direct internet exposure for standard endpoints, the environment utilizes a Dual-Homed Domain Controller. The DC acts as a choke point (router/NAT) between the external network and the isolated Host-Only LAN where Tier 1 and Tier 2 assets reside.

```mermaid
graph TD
    Internet((Internet)) -->|NAT / Outbound| WAN[NIC 1: WAN Interface <br/> 10.0.0.10]
    
    subgraph Hypervisor [KVM / QEMU Virtualized Environment]
        WAN --- DC[Domain Controller <br/> Windows Server 2022 Core]
        DC --- LAN[NIC 2: LAN Interface <br/> 172.16.0.10]
        LAN -->|Host-Only Network| VSwitch{Virtual Switch}
        
        VSwitch --> T1[Tier 1: Application Servers]
        VSwitch --> T2[Tier 2: Windows 10 Endpoints]
    end

    classDef infrastructure fill:#f9f,stroke:#333,stroke-width:2px;
    class DC infrastructure;
```

---

## 2. Active Directory Tiering Model (OU Structure)
The Active Directory structure is strictly aligned with the Microsoft Enterprise Access Model. Administrative privileges are segregated into completely isolated Tiers, preventing lateral movement and credential overlap. The deployment was fully automated via Infrastructure as Code (IaC).

```mermaid
graph TD
    Root[DC=allsafecyber, DC=local] --> AllSafe[OU=AllSafeCorp]
    
    AllSafe --> T0[OU=T0_Infrastructure]
    AllSafe --> T1[OU=T1_Servers]
    AllSafe --> T2[OU=T2_Assets]
    
    AllSafe -.-> Disabled[OU=Disabled_Users]
    AllSafe -.-> Service[OU=Service_Accounts]

    subgraph Tier 0 [Highest Privilege]
        T0 --> T0G[OU=T0_Groups]
        T0 --> EA[OU=Emergency_Accounts <br/> Break-Glass]
    end

    subgraph Tier 2 [Standard Assets]
        T2 --> HR[OU=HR_Dept]
        T2 --> IT[OU=IT_Dept]
        T2 --> MGMT[OU=Management]
        
        HR --> U_HR[OU=Users]
        HR --> C_HR[OU=Computers]
    end

    style Tier 0 fill:#ffe6e6,stroke:#ff0000,stroke-width:2px;
    style Tier 2 fill:#e6f3ff,stroke:#0066cc,stroke-width:2px;
```

---

## 3. Role-Based Access Control (RBAC) & NTFS Isolation
To enforce the Zero Trust principle of **Least Privilege**, file system inheritance is broken at the root level ("Deny by Default"). Access is explicitly granted through security groups dynamically assigned during the automated provisioning phase.

```mermaid
flowchart LR
    subgraph HR Department
        UserA([Angela - HR User]) -->|Member of| HRGroup[HR_Users Group]
    end

    subgraph IT Department
        UserB([Lloyd - IT User]) -->|Member of| ITGroup[IT_Users Group]
    end

    subgraph SMB Share / Corporate_Shares
        HRFolder{/HR_Data}
        ITFolder{/IT_Data}
    end

    HRGroup -->|Explicit Allow: Modify| HRFolder
    ITGroup -.->|Access Denied | HRFolder
    
    ITGroup -->|Explicit Allow: Modify| ITFolder
    HRGroup -.->|Access Denied | ITFolder

    style HRFolder fill:#d9ead3,stroke:#38761d
    style ITFolder fill:#c9daf8,stroke:#1155cc
```
