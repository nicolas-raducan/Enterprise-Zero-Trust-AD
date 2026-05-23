# Create the Tier 2 GPO
	$GpoName = "AllSafe_T2_Baseline"
	New-GPO -Name $GpoName -Comment "CIS Endpoint Baseline: Screen lock and USB deny."

# Link the GPO to the Tier 2 Assets OU and force Enforcement
	New-GPLink -Name $GpoName -Target "OU=T2_Assets,OU=AllSafeCorp,DC=allsafecyber,DC=local" -Enforced Yes

# Enforce 15 minute screen lock
	$DeskPol = "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop"
	Set-GPRegistryValue -Name $GpoName -Key $DeskPol -ValueName "ScreenSaveActive" -Type String -Value "1"
	Set-GPRegistryValue -Name $GpoName -Key $DeskPol -ValueName "ScreenSaverIsSecure" -Type String -Value "1"
	Set-GPRegistryValue -Name $GpoName -Key $DeskPol -ValueName "ScreenSaveTimeOut" -Type String -Value "900"

# Disable USB Removable Storage
	$UsbPol = "HKLM\System\CurrentControlSet\Services\USBSTOR\"
	Set-GPRegistryValue -Name $GpoName -Key $UsbPol -ValueName "Start" -Type Dword -Value 4

Write-Output "Tier 2 Baseline GPO successfully generated and linked."
