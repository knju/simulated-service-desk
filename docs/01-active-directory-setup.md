# 03 — Active Directory Domain Services (AD DS) Setup

## Objective
Stand up a primary Domain Controller (DC) for the `knju.lab` forest to serve as the centralized identity management and authentication backbone for the simulated enterprise environment.

## Environment
- **OS:** Windows Server 2025 VM (6 GB RAM, 4 vCPU)
- **Hostname:** `knjuLAB-DC01`
- **Static IP:** `192.168.122.10`
- **Preferred DNS:** `192.168.122.10` (Loopback / Self)
- **Domain Name:** `knju.lab`

## Steps Taken

### 1. Network & Hostname Configuration
Before installing any roles, I configured the server's foundation:
- Set a static IP address (`192.168.122.10`), subnet mask, and default gateway.
- Set the Preferred DNS server to the server's own IP address (`192.168.122.10`). *Note: A domain controller must point to itself (or another DC) for DNS to ensure it can register its own SRV records for Active Directory.*
- Renamed the server from the random default to `knjuLAB-DC01` and rebooted.

### 2. Role Installation
- Opened **Server Manager** > **Add Roles and Features**.
- Selected **Active Directory Domain Services (AD DS)**. Accepted the prompt to add required features.
- Proceeded through the wizard to install the role binaries (no configuration is done at this stage).

### 3. Domain Controller Promotion
- After installation, clicked the yellow notification flag in Server Manager and selected **Promote this server to a domain controller**.
- Selected **"Add a new forest"** and entered the root domain name: `knju.lab`.
- Set the **Directory Services Restore Mode (DSRM)** password (stored securely for disaster recovery).
- Left the **DNS Options** at default.
- Accepted the default NetBIOS name (`KNJU`) and database/log folder paths.
- Ran the Prerequisites Check and clicked **Install**. The server automatically rebooted upon completion.

## Problems Encountered

**DNS Delegation Warning:**
During the promotion wizard (DNS Options page), I received a yellow warning: *"A delegation for this DNS server cannot be created because the authoritative parent zone cannot be found..."*
- **Root Cause:** This occurs because I am creating a brand new, isolated root domain (`knju.lab`). The wizard is trying to find a parent DNS zone (like `.com` or `.local`) to delegate to, which does not exist in this lab environment.
- **Resolution:** This is expected behavior for a new forest. I left the **"Create DNS delegation"** box unchecked and proceeded. No action was required.

**External DNS Resolution (The Forwarder Rule):**
I initially questioned how the server would resolve external domain names (like `google.com`) if its DNS client points to itself. 
- **Resolution:** The DNS *client* setting on the NIC points to the server itself so it can resolve internal AD queries. To resolve external names, I configured a **DNS Forwarder** inside the DNS Manager console, pointing to an upstream public DNS (e.g., `8.8.8.8`). This separation allows internal AD resolution and internet access to coexist without breaking the domain.

## Verification
After the automatic reboot, I logged in using the new domain administrator credentials (`KNJU\Administrator`). 
- Opened Server Manager and confirmed that **AD DS** and **DNS** roles are listed on the dashboard.
- Opened Active Directory Users and Computers (ADUC) and verified the `knju.lab` domain tree is visible.
- Ran `nslookup www.google.com` on the DC, which successfully returned a public IP address via the configured `8.8.8.8` forwarder.

## Key Takeaways
- **The Local Admin account is replaced.** After promotion, the local `Administrator` account becomes the Domain Administrator. If the domain is unreachable, the only way to log in is using the DSRM password (via Directory Services Restore Mode).
- **Promotion is a one-way operation.** You cannot easily "un-promote" a domain controller. Taking a VM snapshot before running the wizard is a critical best practice.
- **DNS Client vs. DNS Server.** Understanding that the NIC's DNS setting and the DNS Manager's Forwarders are two separate layers is crucial for keeping AD functional while maintaining internet connectivity.