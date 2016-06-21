# (C) Marcin Bojko
# $VER 1.12
# 2016-06-21

# Hyper-V default firewall settings
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"
Enable-NetFirewallRule -DisplayGroup "Remote Service Management"
Enable-NetFirewallRule -DisplayGroup "Performance Logs and Alerts"
Enable-NetFirewallRule -DisplayGroup "Remote Event Log Management"
Enable-NetFirewallRule -DisplayGroup "Remote Scheduled Tasks Management"
Enable-NetFirewallRule -DisplayGroup "Remote Volume Management"
Enable-NetFirewallRule -DisplayGroup "Windows Firewall Remote Management"
Enable-NetFirewallRule -DisplayGroup "Windows Management Instrumentation (WMI)"
Enable-NetFirewallRule -DisplayGroup "Remote Service Management"
Enable-NetFirewallRule -DisplayGroup "Hyper-v Replica HTTP"
Enable-NetFirewallRule -DisplayGroup "Hyper-v Replica HTTPS"
Enable-NetFirewallRule -DisplayGroup "iSCSI Service" -Direction "Outbound"
Enable-NetFirewallRule -DisplayGroup "iSCSI Service" -Direction "Inbound"
Enable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)"

# Install features
Install-WindowsFeature net-framework-core
Install-WindowsFeature net-framework-features
Install-WindowsFeature EnhancedStorage -IncludeManagementTools
Install-WindowsFeature Failover-Clustering -IncludeManagementTools
Install-WindowsFeature Multipath-IO -IncludeManagementTools
Install-WindowsFeature SNMP-Service -IncludeManagementTools
Install-WindowsFeature SNMP-WMI-Provider -IncludeManagementTools
Install-WindowsFeature Telnet-Client
Install-WindowsFeature RSAT-Role-Tools
Install-WindowsFeature PowerShell-V2


#Enable Remote Desktop features
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
# Disable NLA
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 0

#Disable VMQ for 1Gbit NIC for every NIC
Get-NetAdapterVmq|Set-NetAdapterVmq -Enabled $False
Start-Sleep -Seconds 5

#Enable Jumbo Frames (6K=6144) for every NIC
Get-NetAdapter | Where-Object -FilterScript {($_.Status -eq "Up") -and ($_.Name -like "Ethern*") }|Set-NetAdapterAdvancedProperty -RegistryKeyword "*JumboPacket" -RegistryValue 6144
Start-Sleep -Seconds 5

# Start Services
Set-Service -Name MSiSCSI -StartupType Automatic
Start-Service MSiSCSI
Set-Service -Name vds -StartupType Automatic
Start-Service vds

# Install chocolatey
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

# Add local source
choco source add -n=eLeader -s"https://www.myget.org/F/eleader/api/v2" --priority=10

# Install puppet and configure to access foreman.eleader.lan
choco install puppet -ia '"PUPPET_MASTER_SERVER=foreman.eleader.lan"' -y

# Disable Puppet not to run before changing the name
Stop-Service puppet
Set-Service -Name puppet -StartupType Automatic

# install extrapackages required (ready to be modified)
choco install doublecmd sysinternals -y

#Ask for name, renam and join domain
$newcomputername = Read-Host -Prompt "Podaj nazwę komputera pod jaką zostanie dołączony do domeny"
$cred = Get-Credential
Add-Computer -DomainName "eleader.lan" -Credential $cred -OUPath "OU=Servers-HyperV,DC=eleader,DC=lan"
Rename-Computer -NewName $newcomputername -DomainCredential $cred -Force

#Restart-Computer





