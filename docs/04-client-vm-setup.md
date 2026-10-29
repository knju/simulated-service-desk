# 06 — Client Workstation Setup & Domain Join

## Objective
Provision a standard Windows 10/11 client workstation (`knjuLAB-W10`) to simulate the environment used by the Helpdesk technician. This VM will be used to verify that the delegation of control boundaries configured on the Domain Controller operate correctly from a standard, non-privileged endpoint.

## Environment
- **OS:** Windows 10 Pro
- **Hostname:** `knjuLAB-W10`
- **IP Address:** `192.168.122.50`
- **DNS Server:** `192.168.122.10` (Domain Controller)
- **Domain:** `knju.lab`

## Steps Taken

### 1. Network Configuration
Configured a static IP address on the client VM. 
**Critical Design Choice:** The Preferred DNS server was set to the IP of the Domain Controller (`192.168.122.10`), not a public resolver (like 8.8.8.8). Without this, the client cannot locate the AD domain (`knju.lab`) to authenticate users.

### 2. Domain Join
1. Opened **Settings** > **Accounts** > **Add Work or School Account**
2. Selected **Sign into a Local Active Directory Domain**, entering `knju.lab`.
3. Authenticated using the Domain Administrator credentials (`LAB\Administrator`).
4. Rebooted the VM to apply the changes.

### 3. Tooling (RSAT Installation)
A standard Windows client does not have the Active Directory management tools installed by default. Opened PowerShell as Administrator and installed the RSAT AD DS tools via Windows Capabilities:
```powershell
Add-WindowsCapability –online –Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"
```
## Key Takeaways
- **DNS is the backbone of Active Directory.** The domain join initially failed because I attempted it before changing the client's DNS to point to the DC. Once the DNS was corrected, authentication and domain joining worked instantly.
- **Separation of Duties.** By running these tests from a standard client workstation rather than the Domain Controller itself, I proved that the permissions are tied strictly to the user's account (`test.helpdesk`) and the ACLs applied to the OU, not the physical machine being used.
- **The negative test is the ultimate proof.** It is easy to configure a permission and assume it works. Actively attempting to breach the boundary (resetting the HR user's password) and receiving a hard "Access Denied" is the only way to prove the security scope is correctly locked down.