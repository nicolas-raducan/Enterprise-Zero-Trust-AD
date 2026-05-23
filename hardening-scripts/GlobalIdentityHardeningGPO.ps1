# Enforce password and lockout policies at the Domain root
	Set-ADDefaultDomainPasswordPolicy -Identity "allsafecyber.local" `
    		-ComplexityEnabled $true `
    		-MinPasswordLength 14 `
    		-MaxPasswordAge (New-TimeSpan -Days 60) `
    		-LockoutThreshold 5 `
    		-LockoutObservationWindow (New-TimeSpan -Minutes 15) `
    		-LockoutDuration (New-TimeSpan -Minutes 15)

	Write-Output "Global Password and Lockout Policies succesfully enforced"
