# Simulated Service Desk — AD Lifecycle & SLA-Driven Support

## Business Context
This lab simulates a small enterprise IT support environment to practice L2 service desk workflows: ticket intake, SLA tracking, Active Directory identity lifecycle management, and PowerShell-based resolution automation.

## What I Built
- **Ticketing:** osTicket (v1.18.1) deployed on a LAMP stack (Ubuntu Server 26.04.1 LTS VM) with Active Directory LDAP integration
- **SLA Framework:** Sev-A to Sev-D priority matrix with 24/7 and business-hours response/resolution targets automated via Help Topics
- **Directory Services:** Windows Server 2025 primary domain controller (`knju.lab`)
- **AD Structure:** Departmental OUs (`IT`, `HR`, `Sales`) under a `CORP` root with least-privilege Helpdesk delegation enforced via `dsacls`
- **Automation:** PowerShell scripts for bulk CSV user onboarding, password resets/unlocks, and secure user offboarding
- **Runbooks:** 3 documented resolution procedures (`RB-001` to `RB-003`) with verification steps and escalation criteria

## Architecture

```text
+-----------------------------------------------------------------------+
|                        Lab Network: 192.168.122.0/24                  |
+-----------------------------------------------------------------------+
        |                                   |                         |
        | .10                               | .20                     | .50
+-------+---------------+   LDAPS   +-------+---------------+ +-------+---------------+
|     knjuLAB-DC01      |<--------->|     osTicket Server   | |     knjuLAB-W10       |
|  Windows Server 2025  |  (636/389)| Ubuntu Server 26.04.1 | |    Windows 10 Pro     |
+-----------------------+           +-----------------------+ +-----------------------+
| - AD DS (knju.lab)    |           | - Apache / MariaDB    | | - Domain Joined       |
| - DNS Server          |           | - PHP 8.2 (Sury repo) | | - RSAT AD DS Tools    |
|   (Forwarder: 8.8.8.8)|           | - osTicket v1.18.1    | | - PowerShell Scripts  |
| - Self-Signed LDAPS   |           | - AD LDAP Auth Plugin | | - RBAC Boundary Tests |
+-----------------------+           +-----------------------+ +-----------------------+
```

- **`knjuLAB-DC01` (`192.168.122.10`):** Windows Server 2025 VM (4 vCPU, 6 GB RAM) acting as the primary Domain Controller and DNS server for the `knju.lab` forest, configured with upstream DNS forwarding (`8.8.8.8`) and self-signed certificates for LDAPS.
- **osTicket Server (`192.168.122.20`):** Ubuntu Server 26.04.1 LTS VM running a LAMP stack (Apache, MariaDB, PHP 8.2) hosting osTicket v1.18.1, integrated with Active Directory for agent authentication and automated SLA tracking.
- **`knjuLAB-W10` (`192.168.122.50`):** Domain-joined Windows 10 Pro workstation equipped with RSAT and PowerShell scripts, simulating the L2 Helpdesk technician endpoint for executing runbooks and verifying security boundaries.

## Key Evidence
- [AD DS Setup](docs/01-active-directory-setup.md)
- [OU Structure & Data Population](docs/02-ou-structure.md)
- [Delegation of Control proof](docs/03-delegation-of-control.md)
- [Client Workstation Setup](docs/04-client-vm-setup.md)
- [Ticketing System & AD Integration](docs/05-ticketing-system-setup.md)
- [SLA Framework definitions](docs/06-sla-framework.md)
- [PowerShell automation & Runbook library](docs/runbooks)

## What I Learned
The most challenging issues I solved were bypassing a Windows Server GUI limitation that hid the "Extended Rights" checkbox when scoping OU delegation, and resolving an LDAPS handshake failure (`errno=104`) caused by Windows Server 2025's strict default LDAP signing enforcement. To establish deterministic least-privilege access, I pivoted from the graphical wizard to `dsacls.exe` in PowerShell, scripting exact Access Control Entries so the `Helpdesk-Team` could reset passwords and unlock accounts in the `Sales` OU while being explicitly denied access to `HR`. For the osTicket LDAP integration, I diagnosed the TLS connection reset locally using `ldp.exe`, provisioned a self-signed certificate with the Server Authentication EKU in the Trusted Root store, granted `NETWORK SERVICE` read permissions to the private key, and cleared the NTDS registry certificate cache.

## Disclaimer
All work was performed in a personal lab environment. No production systems or real user data were involved.