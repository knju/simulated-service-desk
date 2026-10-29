# RB-002 — New Starter Onboarding

**Severity scope:** Sev-D (Low - Scheduled Request)
**Ticket Types:** "New Hire", "Onboarding", "Account Provisioning"
**Required Access:** Member of `Helpdesk-Team` (Delegated on target OU)

## Objective
Standardize and automate the creation of new user accounts based on an HR-provided CSV file. This eliminates manual data entry errors, ensures consistent OU placement, and drastically reduces the time required to onboard a new employee.

## Prerequisites
- Obtain the completed `NewUsers.csv` from HR.
- The CSV must contain the following headers: `FirstName`, `LastName`, `Department`, `JobTitle`, and `Manager`.
- The `Department` value must exactly match an existing Organizational Unit (Sales, HR, or IT).

## Procedure
1. Save the HR-provided file to `C:\Scripts\NewUsers.csv` on the management workstation.
2. Open PowerShell as an Administrator.
3. Navigate to the scripts directory and execute the onboarding automation:
   ```powershell
   cd C:\Scripts
   .\New-StarterOnboarding.ps1
   ```
4. The script performs the following actions automatically:
   - Generates the `SamAccountName` (first initial + last name) and UPN.
   - Checks Active Directory to prevent duplicate accounts.
   - Maps the Department to the correct OU path.
   - Creates the user, sets the Job Title, Manager, and a default temporary password.
   - Forces a password change at next logon.
   - Adds the user to their respective departmental security group (e.g., `Sales-Team`).

## Execution Evidence
**Input CSV (`NewUsers.csv`):**
```csv
FirstName,LastName,Department,JobTitle,Manager
John,Doe,Sales,Sales Associate,test.sales1
Jane,Smith,HR,HR Coordinator,test.hr1
Mike,Ross,IT,Junior Sysadmin,Administrator
Alvaro,Felices,HR,HR User,test.sales1
```

**PowerShell Output:**
```text
PS C:\Scripts> .\New-StarterOnboarding.ps1
SUCCESS: Created user John Doe (jdoe) in Sales
  -> Added to group: Sales-Team
SUCCESS: Created user Jane Smith (jsmith) in HR
  -> Added to group: HR-Team
SKIPPING: User mross already exists.
SUCCESS: Created user Alvaro Felices (afelices) in HR
  -> Added to group: HR-Team
```

## Verification
1. Open **Active Directory Users and Computers (ADUC)**.
2. Navigate to the respective department OUs (e.g., `CORP\Sales\Users`) and verify the new user objects exist.
3. Verify that the `Manager` attribute is populated correctly by checking the user's "Organization" tab.
4. Confirm the user was added to the correct Security Group.

## Escalation Criteria
- The CSV is missing required columns or contains invalid formatting.
- The requested Department does not match an existing OU in the script.
- The Manager's account does not exist in Active Directory.

## Key Takeaways
- **Idempotency is critical.** The script includes a check (`Get-ADUser`) before creating a user. As proven in the execution evidence (`SKIPPING: User mross already exists`), this prevents the script from crashing or creating duplicate accounts if run multiple times.
- **Standardization.** By forcing the `SamAccountName` format to `firstinitial+lastname`, we prevent inconsistencies (e.g., "John.Doe" vs "JDoe") and ensure a predictable naming convention across the enterprise.
- **Security.** The script forces a password change at the next logon, ensuring the Helpdesk technician never knows the user's permanent password.