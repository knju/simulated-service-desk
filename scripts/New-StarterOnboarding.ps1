# New-StarterOnboarding.ps1

# 1. Define the CSV path (Change this if you saved it elsewhere)
$CsvPath = "C:\Scripts\NewUsers.csv"

# 2. Define the Default Password (must meet complexity requirements)
$DefaultPassword = ConvertTo-SecureString "WelcomeToTheCompany2026!" -AsPlainText -Force

# 3. Import the CSV
$Users = Import-Csv -Path $CsvPath

foreach ($User in $Users) {
    # Build the Display Name and SamAccountName
    $DisplayName = "$($User.FirstName) $($User.LastName)"
    $SamAccountName = ($User.FirstName.Substring(0,1) + $User.LastName).ToLower()
    $UPN = "$SamAccountName@knju.lab"

    # 4. Determine the OU based on the Department in the CSV
    $TargetOU = switch ($User.Department) {
        "Sales" { "OU=Users,OU=Sales,OU=CORP,DC=knju,DC=lab" }
        "HR"    { "OU=Users,OU=HR,OU=CORP,DC=knju,DC=lab" }
        "IT"    { "OU=Users,OU=IT,OU=CORP,DC=knju,DC=lab" }
        default { "OU=Users,OU=CORP,DC=knju,DC=lab" } # Fallback
    }

    # 5. Check if user already exists
    if (Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue) {
        Write-Host "SKIPPING: User $SamAccountName already exists." -ForegroundColor Yellow
        continue
    }

    # 6. Create the User
    try {
        New-ADUser `
            -Name $DisplayName `
            -GivenName $User.FirstName `
            -Surname $User.LastName `
            -SamAccountName $SamAccountName `
            -UserPrincipalName $UPN `
            -DisplayName $DisplayName `
            -Department $User.Department `
            -Title $User.JobTitle `
            -Manager $User.Manager `
            -Path $TargetOU `
            -AccountPassword $DefaultPassword `
            -ChangePasswordAtLogon $true `
            -Enabled $true `
            -ErrorAction Stop

        Write-Host "SUCCESS: Created user $DisplayName ($SamAccountName) in $($User.Department)" -ForegroundColor Green
        
        # 7. (Optional) Add to a Department Security Group
        $GroupName = "$($User.Department)-Team"
        if (Get-ADGroup -Filter "Name -eq '$GroupName'" -ErrorAction SilentlyContinue) {
            Add-ADGroupMember -Identity $GroupName -Members $SamAccountName
            Write-Host "  -> Added to group: $GroupName" -ForegroundColor Cyan
        }

    } catch {
        Write-Host "ERROR creating $DisplayName : $_" -ForegroundColor Red
    }
}
