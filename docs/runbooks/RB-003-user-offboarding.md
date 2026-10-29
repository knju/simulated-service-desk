# RB-003 — User Offboarding (Termination)

**Severity scope:** Sev-B (High - Security Risk)
**Ticket Types:** "Termination", "Offboarding", "User Leaving"
**Required Access:** Member of `Helpdesk-Team` or Domain Admin

## Objective
Immediately revoke all access for a departing employee to prevent security breaches or data exfiltration, while retaining the user object for auditing and mailbox delegation purposes.

## Resolution Steps
1. Open PowerShell on the management workstation as an Administrator.
2. Run the offboarding script:
   ```powershell
   cd C:\Scripts
   .\Disable-UserOffboarding.ps1
   ```
3. Enter the user's `SamAccountName`.
4. The script will automatically:
   - Disable the Active Directory account.
   - Strip all security group memberships (revoking access to file shares, VPNs, etc.).
   - Move the user object to the `Disabled Users` OU (to keep the active `CORP` OUs clean).

**Output:**
```powershell
.\Disable-UserOffboarding.ps1
Enter the username to offboard (e.g., jdoe): jdoe
Account disabled.
Removed from all security groups.
User moved to Disabled Users OU.
SUCCESS: jdoe has been fully offboarded.
```
## Verification
- Open ADUC and verify the user's icon has a downward arrow (disabled).
- Verify the user is no longer in any departmental security groups.
- Ask the user's manager to confirm the user can no longer log in.

## Escalation Criteria
- User is a Domain Admin (Requires Tier 3 approval before offboarding).
- Legal hold is requested by HR (Do not delete data, only disable).