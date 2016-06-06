::(C) Marcin Bojko
::$VER 1.08
::2016-06-25

cd /d %~dp0

@echo off

:: Hyper-V default firewall settings
netsh advfirewall set currentprofile settings remotemanagement enable
@powershell Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
@powershell Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing" 
@powershell Enable-NetFirewallRule -DisplayGroup "Remote Service Management" 
@powershell Enable-NetFirewallRule -DisplayGroup "Performance Logs and Alerts" 
@powershell Enable-NetFirewallRule -DisplayGroup "Remote Event Log Management" 
@powershell Enable-NetFirewallRule -DisplayGroup "Remote Scheduled Tasks Management"
@powershell Enable-NetFirewallRule -DisplayGroup "Remote Volume Management"
@powershell Enable-NetFirewallRule -DisplayGroup "Windows Firewall Remote Management"
@powershell Enable-NetFirewallRule -DisplayGroup "Windows Management Instrumentation (WMI)"
@powershell Enable-NetFirewallRule -DisplayGroup "Remote Administration"
@powershell Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
@powershell Enable-NetFirewallRule -DisplayGroup "Hyper-v Replica HTTP"
@powershell Enable-NetFirewallRule -DisplayGroup "Hyper-v Replica HTTPS"

:: ISCSI settings
netsh advfirewall firewall set rule group="iSCSI Service" new enable=yes

::SNMP
dism /online /enable-feature /featurename:SNMP

:: Allow PING
netsh firewall set icmpsetting 8

::Set vd service on start
::sc config vds start= auto
::net start vds


:: Install features
powershell Install-WindowsFeature net-framework-core
powershell Install-WindowsFeature net-framework-features
powershell Install-WindowsFeature EnhancedStorage -IncludeManagementTools
powershell Install-WindowsFeature Failover-Clustering -IncludeManagementTools
powershell Install-WindowsFeature Multipath-IO -IncludeManagementTools
powershell Install-WindowsFeature SNMP-Service -IncludeManagementTools
powershell Install-WindowsFeature SNMP-WMI-Provider -IncludeManagementTools
powershell Install-WindowsFeature Telnet-Client 
powershell Install-WindowsFeature Windows-Server-Backup
powershell Install-WindowsFeature RSAT-Role-Tools
powershell Install-WindowsFeature RSAT-Hyper-V-Tools
powershell Install-WindowsFeature Hyper-V-PowerShell
powershell Install-WindowsFeature PowerShell-V2 


:: Start Services
powershell Set-Service -Name MSiSCSI -StartupType Automatic
powershell Start-Service MSiSCSI
powershell Set-Service -Name vds -StartupType Automatic
powershell Start-Service vds

:: Set authentication
winrm set winrm/config/service/auth @{CredSSP="true"}
 
:: Install chocolatey
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

:: Install puppet and configure to access foreman.eleader.lan
choco install puppet -ia '"PUPPET_MASTER_SERVER=foreman.office.eleader.biz"' -y
choco install doublecmd

