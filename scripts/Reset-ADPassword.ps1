# Reset-ADPassword.ps1

# 1. Prompt for the username
$Username = Read-Host -Prompt "Enter the username to reset (e.g., test.sales1)"

# 2. Verify the user exists
try {
    $User = Get-ADUser -Identity $Username -Properties LockedOut, DisplayName -ErrorAction Stop
    Write-Host "Found user: $($User.DisplayName)" -ForegroundColor Cyan
} catch {
    Write-Host "ERROR: User '$Username' not found in Active Directory." -ForegroundColor Red
    Exit
}

# 3. Prompt for the new password securely
do {
    $NewPassword = Read-Host -Prompt "Enter the new temporary password" -AsSecureString
    $ConfirmPassword = Read-Host -Prompt "Confirm the new temporary password" -AsSecureString
    
    # Convert to plain text just to compare if they match
    $PlainPass1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($NewPassword))
    $PlainPass2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ConfirmPassword))

    if ($PlainPass1 -ne $PlainPass2) {
        Write-Host "Passwords do not match. Try again." -ForegroundColor Yellow
    }
} while ($PlainPass1 -ne $PlainPass2)

# 4. Reset the password and force change at next logon
Set-ADAccountPassword -Identity $User -NewPassword $NewPassword -Reset
Set-ADUser -Identity $User -ChangePasswordAtLogon $true

# 5. Unlock the account if it is locked
if ($User.LockedOut -eq $true) {
    Unlock-ADAccount -Identity $User
    Write-Host "Note: Account was locked. Account has been unlocked." -ForegroundColor Yellow
}

# 6. Output for the ticket notes
Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "SUCCESS: Password reset for $($User.DisplayName) ($Username)." -ForegroundColor Green
Write-Host "User must change password at next logon." -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
