# Verify Active Directory Domain Services module is available
    Get-WindowsFeature -Name "RSAT-AD-Powershell"
    Get-WindowsFeature -Name "AD-Domain-Services"

# Install AD DS module
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Promote device to Domain Controller by creating a new AD Forest
    Install-ADDSForest -DomainName "allsafecyber.local" 

# Script to set up DNS ListenAddressess

	# Create a string array variable to store the IP Addressess
	    [String[]]$SecureIPs = "172.16.0.10", "127.0.0.1"
	
	# Write to the registry, defining the variable as Multi String
	    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\DNS\Parameters" -Name "listenAddresses" -Value $SecureIPs -Type MultiString
	
	# Restart DNS Service
	    Restart-Service DNS

# Set up DNS Forwarders
    Set-DnsServerForwarder -IPAddress 8.8.8.8, 1.1.1.1 -UseRootHint $true

# Install DHCP service
    Install-WindowsFeature DHCP -IncludeManagementTools

# Add DHCP to security group
    Add-DhcpServerSecurityGroup

# Restart dhcpservice
    Restart-Service dhcpserver

# Add DHCP server in AD

    Add-DhcpServerInDC -DnsName "$env:COMPUTERNAME.allsafecyber.local" -IPAddress 172.16.0.10

# Add DHCP scope

    Add-DhcpServerv4Scope -Name "AllSafe Security Network" -StartRange 172.16.0.100 -EndRange 172.16.0.200 -SubnetMask 255.255.255.0

# Set DHCP options for DNS and DefaultGateway

    Set-DhcpServerv4OptionValue -DnsServer 172.16.0.10 -Router 172.16.0.10


# Virtual Machine Only Routing with 2 NICs
# Establish NAT Routing


# Intall Routing features and Remote Access Powershell modules
    Install-WindowsFeature Routing, RSAT-RemoteAccess-PowerShell -IncludeManagementTools

# Force module into memory and initialize routing engine
    Import-Module RemoteAccess
    Install-RemoteAccess -VpnType RoutingOnly

# Start service automatically on boot
    Set-Service RemoteAccess -StartupType Automatic
    Start-Service RemoteAccess

# Configure NAT boundaries using network shell
    netsh routing ip nat install
    netsh routing ip nat add interface name="Ethernet" mode=full
    netsh routing ip nat add interface name="Ethernet2" mode=private

Write-Output "NAT Routing successfully established. Server is now acting as a gateway."
