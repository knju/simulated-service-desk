# Disable-UserOffboarding.ps1

$Username = Read-Host -Prompt "Enter the username to offboard (e.g., jdoe)"

try {
    $User = Get-ADUser -Identity $Username -Properties MemberOf -ErrorAction Stop
    
    # 1. Disable the account
    Disable-ADAccount -Identity $User
    Write-Host "Account disabled." -ForegroundColor Yellow

    # 2. Remove all group memberships (except Domain Users)
    $Groups = $User.MemberOf
    foreach ($Group in $Groups) {
        Remove-ADGroupMember -Identity $Group -Members $User -Confirm:$false
    }
    Write-Host "Removed from all security groups." -ForegroundColor Yellow

    # 3. Move to a Disabled Users OU (Create this OU in ADUC first!)
    $DisabledOU = "OU=Disabled Users,DC=knju,DC=lab"
    Move-ADObject -Identity $User.DistinguishedName -TargetPath $DisabledOU
    Write-Host "User moved to Disabled Users OU." -ForegroundColor Yellow

    Write-Host "SUCCESS: $Username has been fully offboarded." -ForegroundColor Green
} catch {
    Write-Host "ERROR: Could not offboard user. Check if the user exists and the 'Disabled Users' OU is correct." -ForegroundColor Red
}
