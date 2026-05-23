# Get network adapter(s)
   Get-NetAdapter

# Set up a static IP Address using the ifIndex for the right network interface
   New-NetIPAddress -InterfaceIndex 7 -IPAddress 10.0.0.10 -PrefixLength -24 -DefaultGateway 10.0.0.1

# Set up DNS
   Set-DNSClientServerAddress -InterfaceIndex 7 -ServerAddresses 8.8.8.8

# Set static IP for the isolated network
   New-NetIPAddress -InterfaceIndex 6 -IPAddress 172.16.0.10 -PrefixLength -24 

# Set up DNS for isolated network
   Set-DNSClientServerAddress -InterfaceIndex 6 -ServerAddresses 127.0.0.1

# Change hostname
   Rename-Computer -NewName "DC1" -Force | Restart-Computer -Force

# Set up OpenSSH for remote access for administration
   
   # Check if OpenSSh is already installed
   Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
   
   # Install the server components
   Add-WindowsCapability -Online -Name OpenSSH.Server

   # Start the sshd service
   Start-Service sshd
   
   # Set sshd service to start on boot
   Set-Service -Name sshd -StartupType 'Automatic'

   # Confirtm firewall rule is configured.
   if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
   } else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}

