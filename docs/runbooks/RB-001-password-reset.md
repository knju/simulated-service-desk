# RB-001 — Password Reset / Account Unlock

**Severity scope:** Sev-C (Single user)
**Ticket Types:** "Password Reset", "Account Lockout", "Cannot Log In"
**Required Access:** Member of `Helpdesk-Team` (Delegated on target OU)

## Objective
Securely reset a user's password and unlock their account using PowerShell automation. This ensures the technician never handles plain-text permanent passwords and guarantees the user is forced to create their own secure password immediately.

## Symptoms
- User reports they forgot their password.
- User is locked out after multiple failed attempts.
- User's password has expired and they cannot change it remotely.

## Before You Begin
Confirm that the user is in an Organizational Unit (OU) where your Helpdesk team has delegated permissions (e.g., `CORP\Sales`). If the user is in an OU you do not have rights to (e.g., `CORP\HR`), **escalate** the ticket—do not attempt to bypass security boundaries.

## Procedure
1. Open PowerShell on the Helpdesk workstation as an Administrator.
2. Navigate to the scripts directory and execute the reset script:
   ```powershell
   cd C:\Scripts
   .\Reset-ADPassword.ps1
   ```
3. When prompted, enter the user's **SamAccountName** (e.g., `jdoe`).
4. Enter a secure, complex temporary password (e.g., `Welcome2026!`) and confirm it.
5. The script will automatically:
   - Verify the user exists.
   - Reset the password.
   - Force the user to change the password at their next logon.
   - Unlock the account if it was locked out.

**Output:**
```powershell
.\Reset-ADPassword.ps1
Enter the username to reset (e.g., test.sales1): test.sales1
Found user: Test Sales1
Enter the new temporary password: ********
Confirm the new temporary password: ********

==========================================
SUCCESS: Password reset for Test Sales1 (test.sales1).
User must change password at next logon.
==========================================
```

## Verification
- Communicate the temporary password to the user via a secure channel (phone call or secure chat).
- Ask the user to log in. They should be immediately prompted to change their password.
- If the user is still unable to log in, verify their account status in ADUC or run:
  ```powershell
  Get-ADUser -Identity <username> -Properties LockedOut, PasswordExpired
  ```

## Ticket Note Template
> Resolved via [RB-001]. Account unlocked and temporary password set via PowerShell. User is required to change password at next logon. Confirmed with user that access is restored. Duration: X min.

## Escalation Criteria
- User is in an OU outside your delegation (Script will return "Access Denied").
- Account is disabled by a security policy (do not re-enable without security team approval).
- Suspected account compromise (e.g., user reports they didn't make the failed login attempts).