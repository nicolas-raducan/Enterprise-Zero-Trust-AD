# Create Organizational Unit
	$Domain = "DC=allsafecyber,DC=local"
	$ParentOU = "OU=AllSafeCorp,$Domain"
	$InfrastructureOU = "OU=T0_Infrastructure,$ParentOU"
	$ServersOU = "OU=T1_Servers,$ParentOU"
	$AssetsOU = "OU=T2_Assets,$ParentOU"

	# Create Top Wrapper OU
	New-ADOrganizationalUnit -Name "AllSafeCorp" -Path $Domain

	# Create nested architecture inside the top wrapper
	New-ADOrganizationalUnit -Name "T0_Infrastructure" -Path $ParentOU
	New-ADOrganizationalUnit -Name "T1_Servers" -Path $ParentOU
	New-ADOrganizationalUnit -Name "T2_Assets" -Path $ParentOU

	# Create Groups OU for isolated control
	New-ADOrganizationalUnit -Name "T0_Groups" -Path $InfrastructureOU
	New-ADOrganizationalUnit -Name "T1_Groups" -Path $ServersOU
	New-ADOrganizationalUnit -Name "T2_Groups" -Path $AssetsOU 


	# Create specialized OUs inside the top wrapper
	New-ADOrganizationalUnit -Name "Disabled_Users" -Path $ParentOU
	New-ADOrganizationalUnit -Name "Service_Accounts" -Path $ParentOU
	New-ADOrganizationalUnit -Name "Emergency_Accounts" -Path $ParentOU
	
	# Create Departments inside T2_Assets OU wrapper and Users and Computer OUs for each dept

	New-ADOrganizationalUnit -Name "HR_Dept" -Path $AssetsOU 
	New-ADOrganizationalUnit -Name "Red_Team" -Path $AssetsOU 
	New-ADOrganizationalUnit -Name "Blue_Team" -Path $AssetsOU 
	New-ADOrganizationalUnit -Name "IT_Dept" -Path $AssetsOU 
	New-ADOrganizationalUnit -Name "Management" -Path $AssetsOU 
	New-ADOrganizationalUnit -Name "Threat_Intelligence" -Path $AssetsOU 
	
	# HR Department
	New-ADOrganizationalUnit -Name "Computers" -Path "OU=HR_Dept,$AssetsOU" 
	New-ADOrganizationalUnit -Name "Users" -Path "OU=HR_Dept,$AssetsOU" 

	# Red Team 
	New-ADOrganizationalUnit -Name "Computers" -Path "OU=Red_Team,$AssetsOU"
	New-ADOrganizationalUnit -Name "Users" -Path "OU=Red_Team,$AssetsOU"

	# Blue Team 
	New-ADOrganizationalUnit -Name "Computers" -Path "OU=Blue_Team,$AssetsOU"
	New-ADOrganizationalUnit -Name "Users" -Path "OU=Blue_Team,$AssetsOU"
	
	# IT Department 
	New-ADOrganizationalUnit -Name "Computers" -Path "OU=IT_Dept,$AssetsOU"
	New-ADOrganizationalUnit -Name "Users" -Path "OU=IT_Dept,$AssetsOU"

	# Management Department
	New-ADOrganizationalUnit -Name "Computers" -Path "OU=Management,$AssetsOU"
	New-ADOrganizationalUnit -Name "Users" -Path "OU=Management,$AssetsOU"
	
	# Threat_Intelligence
	New-ADOrganizationalUnit -Name "Computers" -Path "OU=Threat_Intelligence,$AssetsOU"
	New-ADOrganizationalUnit -Name "Users" -Path "OU=Threat_Intelligence,$AssetsOU"




# TIER 0 & TIER 1 SECURITY GROUP CREATION (ADMINISTRATIVE RBAC)
	Write-Output "Generating Tier 0 and Tier 1 Administrative Security Groups..."

# Tier 0 Groups (Identity & Infrastructure Control)
	$T0GroupPath = "OU=T0_Groups,$InfrastructureOU"

	New-ADGroup -Name "T0_Identity_Admins" -GroupCategory Security -GroupScope Global -Path $T0GroupPath
	New-ADGroup -Name "T0_Emergency_Access" -GroupCategory Security -GroupScope Global -Path $T0GroupPath

#Tier 1 Groups (Server & Application Control)
	$T1GroupPath = "OU=T1_Groups,$ServersOU"

	New-ADGroup -Name "T1_Server_Admins" -GroupCategory Security -GroupScope Global -Path $T1GroupPath
	New-ADGroup -Name "T1_Database_Admins" -GroupCategory Security -GroupScope Global -Path $T1GroupPath
	New-ADGroup -Name "T1_Web_Admins" -GroupCategory Security -GroupScope Global -Path $T1GroupPath


Write-Output "Tier 0 and Tier 1 Administrative Groups successfully provisioned."




# TIER 2 SECURITY GROUP CREATION (CENTRALIZED RBAC)
Write-Output "Generating Tier 2 Security Groups..."

# Define the precise path to the centralized T2_Groups OU
	$T2GroupPath = "OU=T2_Groups,$AssetsOU"

	Write-Output "Generating Centralized Tier 2 Security Groups..."

# Create the specific security groups for each department
	New-ADGroup -Name "HR_Users" -GroupCategory Security -GroupScope Global -Path $T2GroupPath
	New-ADGroup -Name "Red_Team_Users" -GroupCategory Security -GroupScope Global -Path $T2GroupPath
	New-ADGroup -Name "Blue_Team_Users" -GroupCategory Security -GroupScope Global -Path $T2GroupPath
	New-ADGroup -Name "IT_Users" -GroupCategory Security -GroupScope Global -Path $T2GroupPath
	New-ADGroup -Name "Management_Users" -GroupCategory Security -GroupScope Global -Path $T2GroupPath
	New-ADGroup -Name "Threat_Intelligence_Users" -GroupCategory Security -GroupScope Global -Path $T2GroupPath

Write-Output "Tier 2 Security Groups successfully provisioned."
