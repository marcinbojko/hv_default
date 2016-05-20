::(C) Marcin Bojko
::$VER 1.07
::2015-05-05

cd /d %~dp0

@echo off

:: Hyper-V default firewall settings
netsh advfirewall set currentprofile settings remotemanagement enable
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes
netsh advfirewall firewall set rule group="Remote Service Management" new enable=yes
netsh advfirewall firewall set rule group="Performance Logs and Alerts" new enable=yes
Netsh advfirewall firewall set rule group="Remote Event Log Management" new enable=yes
Netsh advfirewall firewall set rule group="Remote Scheduled Tasks Management" new enable=yes
netsh advfirewall firewall set rule group="Remote Volume Management" new enable=yes
netsh advfirewall firewall set rule group="Windows Firewall Remote Management" new enable =yes
netsh advfirewall firewall set rule group="windows management instrumentation (wmi)" new enable =yes
netsh advfirewall firewall set rule group="Remote Administration" new enable=yes
netsh advfirewall firewall set rule group="Remote Desktop" new enable=yes
netsh advfirewall firewall set rule group="Hyper-v Replica HTTP" new enable=yes
netsh advfirewall firewall set rule group="Hyper-v Replica HTTPS" new enable=yes

:: ISCSI settings
netsh advfirewall firewall set rule group="iSCSI Service" new enable=yes

::SNMP
dism /online /enable-feature /featurename:SNMP


:: Allow PING
netsh firewall set icmpsetting 8

::Set vd service on start
sc config vds start= auto
net start vds


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


powershell Set-Service -Name MSiSCSI -StartupType Automatic
powershell Start-Service MSiSCSI



:: create shares
:: mkdir c:\share
:: net share share=c:\share /grant:Administrator.FULL,Domain Admins.Full

::Copy rhirstmanager
::mkdir C:\Windows\SysWOW64\WindowsPowerShell\v1.0\Modules\RhIrstManager
::robocopy ./Intel/ C:\Windows\SysWOW64\WindowsPowerShell\v1.0\Modules\RhIrstManager


::create LACP
:: powershell New-NetLbfoTeam LACP01 "Ethernet 2" , "Ethernet 4" -TeamingMode Lacp ‑LoadBalancingAlgorithm HyperVPort


::install smartmontools for monitoring S.M.A.R.T. of HDDs
::.\apps\smartmontools-win-6.2-1.exe -f it.hardware@eleader.biz -t it@eleader.biz -s mail.eleader.biz --tls=auto --keepfirstlog=no --ignoretemperature=no --short=S/../.././23 --long=L/../../6/23 --localmessages=yes /silent

::enable autenthication
winrm set winrm/config/service/auth @{CredSSP="true"}
 