# Import the HR Data
$Employees = Import-CSV -Path "C:\Users\adm_ealderson\Desktop\employees.csv"

# Define a standard temporary password
$SecurePassword = ConvertTo-SecureString "Pass123!" -AsPlainText -Force

# Loop through the HR Data from the csv
foreach ($User in $Employees) {
    # Generate Account name and UserPrincipalName
    $SamAccountName = ($User.FirstName.Substring(0,1) + $User.LastName).ToLower()
    $UPN = "$SamAccountName@allsafecyber.local"
    
    # Routing based on the department 
    $TargetOU = "OU=Users,OU=$($User.Department),OU=T2_Assets,OU=AllSafeCorp,DC=allsafecyber,DC=local"

    # Defining the users Active Directory parameters 
    $UserParams = @{
        Name                  = "$($User.FirstName) $($User.LastName)"
        GivenName             = $User.FirstName
        Surname               = $User.LastName
        DisplayName           = "$($User.FirstName) $($User.LastName)"
        SamAccountName        = $SamAccountName
        UserPrincipalName     = $UPN
        Title                 = $User.JobTitle
        Department            = $User.Department
        Path                  = $TargetOU
        AccountPassword       = $SecurePassword
        ChangePasswordAtLogon = $true
        Enabled               = $true
    }
    
   try {
        New-ADUser @UserParams 
        Write-Host " [+] PROVISIONED: $SamAccountName in $($User.Department)" -ForegroundColor Green
    } catch {
        Write-Host " [~] SKIPPED: $SamAccountName (Account already exists or invalid path)" -ForegroundColor DarkGray
    }

    # Security Group Mapping
    $GroupName = switch ($User.Department) {
        "HR_Dept"             { "HR_Users" }
        "IT_Dept"             { "IT_Users" }
        "Management"          { "Management_Users" }
        "Red_Team"            { "Red_Team_Users" }
        "Blue_Team"           { "Blue_Team_Users" }
        "Threat_Intelligence" { "Threat_Intelligence_Users" }
        default               { $null }
    }
    
    if ($GroupName) {
        try {
            Add-ADGroupMember -Identity $GroupName -Members $SamAccountName -ErrorAction Stop
            Write-Host "      -> SECURED: Added to $GroupName" -ForegroundColor DarkGreen
        } catch {
            Write-Host "      -> NOTICE: Already in $GroupName or group missing." -ForegroundColor DarkYellow
        }
    }

}

Write-Host "Pipeline Execution Complete." -ForegroundColor Cyan
