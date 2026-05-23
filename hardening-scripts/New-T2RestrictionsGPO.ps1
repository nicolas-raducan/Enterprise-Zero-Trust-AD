# Create the Living on the Land Restriction GPO
	$GpoName = "AllSafe_Restrict_Tools"
	New-GPO -Name $GpoName -Comment "LotL Mitigation: Blocks CMD, Regedit, and PowerShell for non-technical users."

# Link the GPO to the HR and Management OUs and Enforce it
	New-GPLink -Name $GpoName -Target "OU=HR_Dept,OU=T2_Assets,OU=AllSafeCorp,DC=allsafecyber,DC=local" -Enforced Yes
	New-GPLink -Name $GpoName -Target "OU=Management,OU=T2_Assets,OU=AllSafeCorp,DC=allsafecyber,DC=local" -Enforced Yes

# Disable Command Prompt
	$SysPol = "HKCU\Software\Policies\Microsoft\Windows\System"
	Set-GPRegistryValue -Name $GpoName -Key $SysPol -ValueName "DisableCMD" -Type DWord -Value 1

# Disable Registry Editor
	$RegPol = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System"
	Set-GPRegistryValue -Name $GpoName -Key $RegPol -ValueName "DisableRegistryTools" -Type DWord -Value 2

# Build the "DisallowRun" Blacklist for PowerShell
 	$ExpPol = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
	Set-GPRegistryValue -Name $GpoName -Key $ExpPol -ValueName "DisallowRun" -Type DWord -Value 1

# Add specific executables to the Blacklist
 	$DisallowKey = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun"
	Set-GPRegistryValue -Name $GpoName -Key $DisallowKey -ValueName "1" -Type String -Value "powershell.exe"
	Set-GPRegistryValue -Name $GpoName -Key $DisallowKey -ValueName "2" -Type String -Value "powershell_ise.exe"

Write-Output "LotL Mitigation GPO successfully generated and linked to HR and Management departments."
