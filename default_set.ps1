# (C) Marcin Bojko
# $VER 1.16
# 2016-10-04

# Vars

$ErrorActionPreference      = "Continue"
$my_foreman_server          ='foreman.local'                             # puppet server to add mentioned computer
$my_domain_name             ='domain.local'                              # Active Directory domain name
$my_domain_ou_path          ="OU=Devices,DC=office,DC=eleader,DC=biz"    # OU to add your server
$choco_extra_source         ='https://www.myget.org/F/public-choco'      # If you have additional sources for chocolatey
$choco_extra_source_name    ='marcinbojko'                               # source name
$jumbo_key_value            = 9014                                       # should tweak this, or disable if you have different NICs
$puppet_agent               ='puppet'                                    # puppet = version 3.8, puppet-agent=version 1.7.x (Puppet4)
$source_directory           =''                                          # variable for storing source dir
$choco_packages             =@("doublecmd","sysinternals","powershell")  # packages intended to install wih chocolatey


# Let's check where is sources/sxs
    $our_disks = (get-psdrive –psprovider filesystem).Root
        foreach ($our_disk in $our_disks)
                {
                    $testpath=$our_disk+"sources\sxs\"
                    if (Test-Path $testpath)
                        { Write-Output "Found SXS folder in $our_disk"
                        $source_directory=$testpath
                        break
                        }
                }

# Install features
    if ($source_directory -ne "")
        {
            Install-WindowsFeature net-framework-core -Source $source_directory -ErrorAction SilentlyContinue
            Install-WindowsFeature net-framework-features -Source $source_directory -ErrorAction SilentlyContinue
        }

# If we have Windows Server
Install-WindowsFeature Hyper-V -ErrorAction SilentlyContinue
Install-WindowsFeature EnhancedStorage -IncludeManagementTools
Install-WindowsFeature Failover-Clustering -IncludeManagementTools
Install-WindowsFeature Multipath-IO -IncludeManagementTools
Install-WindowsFeature SNMP-Service -IncludeManagementTools
Install-WindowsFeature SNMP-WMI-Provider -IncludeManagementTools
Install-WindowsFeature Telnet-Client
Install-WindowsFeature RSAT-Role-Tools
Install-WindowsFeature PowerShell-V2


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

# Enable Remote Desktop features
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0

# Disable NLA
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 0

# Disable VMQ for 1Gbit NIC for every NIC
Get-NetAdapterVmq|Set-NetAdapterVmq -Enabled $False
Start-Sleep -Seconds 5

# Enable Jumbo Frames (6K=6144) for every NIC
Get-NetAdapter | Where-Object -FilterScript {($_.Status -eq "Up") -and ($_.InterfaceDescription -notlike "*microsoft*")}|Set-NetAdapterAdvancedProperty -RegistryKeyword "*JumboPacket" -RegistryValue $jumbo_key_value|Restart-NetAdapter
Start-Sleep -Seconds 10

# Start Services
Set-Service -Name MSiSCSI -StartupType Automatic
Start-Service MSiSCSI
Set-Service -Name vds -StartupType Automatic
Start-Service vds

# Install chocolatey
$env:chocolateyUseWindowsCompression = 'false'
(Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')))>$null 2>&1

# Add local source
choco source add -n=$choco_extra_source_name -s"$choco_extra_source" --priority=10

# Install puppet and configure to access foreman server
$my_foreman_server_parsed = "`'`""+$my_foreman_server+"`"`'"
choco install $puppet_agent -ia $($my_foreman_server_parsed) -y --debug

# Disable Puppet not to run before changing the name
Stop-Service puppet -ErrorAction SilentlyContinue
Set-Service -Name puppet -StartupType Automatic -ErrorAction SilentlyContinue

# install extrapackages required (ready to be modified)
choco install $choco_packages -y

# Ask for name, rename and join domain
$newcomputername = Read-Host "Please give new name for the computer"
$cred = Get-Credential
Add-Computer -DomainName $my_domain_name -Credential $cred -OUPath $my_domain_ou_path
Rename-Computer -NewName $newcomputername -DomainCredential $cred -Force

#Optional
Restart-Computer -Confirm -Force