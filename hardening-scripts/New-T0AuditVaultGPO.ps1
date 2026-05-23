# Create the Audit Vault GPO
	$GpoName = "AllSafe_T0_Audit_Vault"
	New-GPO -Name $GpoName -Comment "Enterprise Baseline: High-fidelity logging for Tier 0 Infrastructure."

# Link the GPO to Tier 0
	New-GPLink -Name $GpoName -Target "OU=T0_Infrastructure,OU=AllSafeCorp,DC=allsafecyber,DC=local" -Enforced Yes

# Enable Command Line Visibility
	$AuditPol = "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit"
	Set-GPRegistryValue -Name $GpoName -Key $AuditPol -ValueName "ProcessCreationIncludeCmdLine_Enabled" -Type DWord -Value 1

# Force Override Setting
# For Advanced Audit Policies work and aren't blocked by legacy settings
	$LsapPol = "HKLM\SYSTEM\CurrentControlSet\Control\Lsa"
	Set-GPRegistryValue -Name $GpoName -Key $LsapPol -ValueName "SCENoApplyLegacyAuditPolicy" -Type DWord -Value 1

Write-Output "Forensic Visibility GPO succesfully deployed to Tier 0"
