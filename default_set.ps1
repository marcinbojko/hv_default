# (C) Marcin Bojko
# $VER 1.10
# 2016-06-10

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


# Start Services
Set-Service -Name MSiSCSI -StartupType Automatic
Start-Service MSiSCSI
Set-Service -Name vds -StartupType Automatic
Start-Service vds


# Install chocolatey
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
# Install puppet and configure to access foreman.eleader.lan
choco install puppet -ia '"PUPPET_MASTER_SERVER=foreman.eleader.lan"' -y

# Disable Puppet not to run
Stop-Service puppet

# install extrapackages required
choco install doublecmd,sysinternals,notepadplusplus -y




