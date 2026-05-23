# Hardocded password for automated deployment
# In production, the password would be retrieved from a secure vault such as
# Azure Key Vault or passed as a secure parameter
# Convert plain text to secure string
	$SecurePass = ConvertTo-SecureString "AllSafeTest123!" -AsPlainText -Force

# Create test user
	NEW-ADUser -Name "Test User" -SamAccountName "testuser" -UserPrincipalName "testuser@allsafecyber.local" -AccountPassword $SecurePass -Enabled $true -ChangePasswordAtLogon $false


