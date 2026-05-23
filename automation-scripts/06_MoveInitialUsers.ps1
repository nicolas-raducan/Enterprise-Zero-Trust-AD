# Rename local Administrator account for security
	Set-ADUser -Identity "Administrator" -SamAccountName "emg_recovery" -UserPrincipalName "emg_recovery@allsafecyber.local"
	$OldAdminDN = (Get-ADUser -Identity "emg_recovery").DistinguishedName
	Rename-ADObject -Identity $OldAdminDN -NewName "emg_recovery"

# Define privileged identities for safe automation
	$DomainAdmin = "adm_ealderson"
	$BreakGlass = "emg_recovery"

	# Move the Domain Admin to the Tier 0 Vault
	Get-ADUser -Identity $DomainAdmin | Move-ADObject -TargetPath "OU=T0_Infrastructure,OU=AllSafeCorp,DC=allsafecyber,DC=local"

	# Move the Break Glass Account to the Emergency Account OU
	Get-ADUser -Identity $BreakGlass | Move-ADObject -TargetPath "OU=Emergency_Accounts,OU=T0_Infrastructure,OU=AllSafeCorp,DC=allsafecyber,DC=local"

# Disable the testuser account
	Disable-ADAccount -Identity "testuser"
	
# Move testuser to Disabled_Accounts
	Get-ADUser -Identity "testuser" | Move-ADObject -TargetPath "OU=Disabled_Users,OU=AllSafeCorp,DC=allsafecyber,DC=local"

# Move test computer to T2_Assets
	Get-ADComputer -Identity "Alderson-PC" | Move-ADObject -TargetPath "OU=Computers,OU=IT_Dept,OU=T2_Assets,OU=AllSafeCorp,DC=allsafecyber,DC=local"


Write-Host "Privileged Identity and Account Lifecycle updates completed successfully." -ForegroundColor Green

