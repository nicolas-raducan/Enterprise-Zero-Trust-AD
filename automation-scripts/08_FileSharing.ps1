# Create the Root Corporate Directory and Sub-folders
$RootPath = "C:\Corporate_Shares"
$HRPath = "$RootPath\HR_Data"
$ITPath = "$RootPath\IT_Data"
New-Item -Path $HRPath -ItemType Directory -Force | Out-Null
New-Item -Path $ITPath -ItemType Directory -Force | Out-Null


# Share the Root Folder to the Network
Write-Output "Publishing SMB Share..."
try {
    New-SmbShare -Name "Corporate_Shares" -Path $RootPath -FullAccess "Everyone" -ErrorAction Stop
} catch {
    # If the share already exists from earlier, silently skip it
}


# Apply Strict RBAC (NTFS Permissions)
# Strip default inheritance so standard users can't snoop
Write-Output "Applying Zero Trust ACLs to the Root Directory..."
$RootAcl = Get-Acl $RootPath
$RootAcl.SetAccessRuleProtection($true, $false)

# Grant Domain Admins full control over the root
$AdminRule = New-Object System.Security.AccessControl.FileSystemAccessRule("allsafecyber\Domain Admins", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

# Allow Users to see folder, but not edit the root
$UsersRule = New-Object System.Security.AccessControl.FileSystemAccessRule("allsafecyber\Domain Users", "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow")

# Assign the rules to the root
$RootAcl.AddAccessRule($AdminRule)
$RootAcl.AddAccessRule($UsersRule)
$RootAcl | Set-Acl $RootPath


# Grant HR Group modify access ONLY to the HR Folder
$HrAcl = Get-Acl $HRPath
$HrRule = New-Object System.Security.AccessControl.FileSystemAccessRule("allsafecyber\HR_Users", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$HrAcl.SetAccessRuleProtection($true, $false)
$HrAcl.AddAccessRule($AdminRule)
$HrAcl.AddAccessRule($HrRule)
$HrAcl | Set-Acl $HRPath

# Grant IT Group modify access ONLY to the IT Folder
$ItAcl = Get-Acl $ITPath
$ItRule = New-Object System.Security.AccessControl.FileSystemAccessRule("allsafecyber\IT_Users", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$ItAcl.SetAccessRuleProtection($true, $false)
$ItAcl.AddAccessRule($AdminRule)
$ItAcl.AddAccessRule($ItRule)
$ItAcl | Set-Acl $ITPath

Write-Output "Tier 1 File Shares successfully built and secured via RBAC."

###########

<#
.SYNOPSIS
    Automated File Share and NTFS Permissions Provisioning (RBAC)
.DESCRIPTION
    This script creates department-specific shared folders, applies SMB sharing,
    disables NTFS inheritance (Zero Trust approach), and assigns strict Modify
    permissions only to the designated Active Directory Security Groups.
.AUTHOR
    [Numele Tău] - AllSafeCorp Project
#>

$BaseSharePath = "C:\Shares"
$DomainNetBIOS = "ALLSAFECYBER"

# Create the root Shares folder if it doesn't exist
if (-not (Test-Path $BaseSharePath)) {
    New-Item -Path $BaseSharePath -ItemType Directory -Force | Out-Null
    Write-Host "Created base share directory at $BaseSharePath" -ForegroundColor Green
}

# Define the matrix of folders and their corresponding RBAC Security Groups
$Departments = @(
    @{ Name="HR_Data"; Group="HR_Users" },
    @{ Name="IT_Data"; Group="IT_Users" },
    @{ Name="Red_Team_Data"; Group="Red_Team_Users" },
    @{ Name="Blue_Team_Data"; Group="Blue_Team_Users" },
    @{ Name="Management_Data"; Group="Management_Users" },
    @{ Name="Threat_Intel_Data"; Group="Threat_Intelligence_Users" }
)

Write-Host "Starting automated SMB/NTFS provisioning..." -ForegroundColor Cyan

foreach ($Dept in $Departments) {
    $FolderPath = Join-Path -Path $BaseSharePath -ChildPath $Dept.Name
    $TargetGroup = "$DomainNetBIOS\$($Dept.Group)"

    try {
        # 1. Create physical directory
        New-Item -Path $FolderPath -ItemType Directory -Force | Out-Null
        
        # 2. Create SMB Share (Network visibility)
        # Note: If share exists, this will throw a non-terminating error. Suppressing for clean output.
        New-SmbShare -Name $Dept.Name -Path $FolderPath -FullAccess "Everyone" -ErrorAction SilentlyContinue
        
        # 3. Retrieve current ACL
        $Acl = Get-Acl $FolderPath
        
        # 4. Disable Inheritance (Deny by Default)
        $Acl.SetAccessRuleProtection($true, $false)
        
        # 5. Create and apply explicit allow rule for the specific group
        $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule($TargetGroup, "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
        $Acl.AddAccessRule($Rule)
        
        # 6. Commit the ACL changes
        Set-Acl -Path $FolderPath -AclObject $Acl

        Write-Host "[SUCCESS] Provisioned $($Dept.Name) - Restricted to $TargetGroup" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Failed to provision $($Dept.Name): $_" -ForegroundColor Red
    }
}

Write-Host "File Share provisioning completed." -ForegroundColor Cyan
