# (C) Marcin Bojko
# $VER 1.18
# 2016-10-16

# Static variables

$ErrorActionPreference      = "Continue"
$my_foreman_server          ='foreman.local'                             # puppet server to add mentioned computer
$my_domain_name             ='domain.local'                              # Active Directory domain name
$my_domain_ou_path          ="OU=Devices,DC=example,DC=com"              # OU to add your server
$my_domain_user             ='user@example.com'                          # AD user name
$my_domain_user_password    ='secret'                                    # AD user password
$choco_extra_source         ='https://www.myget.org/F/public-choco'      # If you have additional sources for chocolatey
$choco_extra_source_name    ='marcinbojko'                               # source name
$choco_packages             =@("doublecmd","sysinternals","powershell")  # packages intended to install wih chocolatey
$jumbo_key_value            = 9014                                       # should tweak this, or disable if you have different NICs
$puppet_agent               ='puppet-agent'                              # puppet = version 3.8, puppet-agent=version 1.7.x (Puppet4)
$source_directory           =''                                          # variable for storing source dir
$quiet_mode                 = $false                                     # variable for setting quiet/script mode, default: $false

# if possible - override from file hv_default.txt

If (Test-Path -Path './hv_default.txt') {
    $file = get-content hv_default.txt
    $file | foreach {
        $items = $_ -split ' = '
        if ($items[0] -eq "my_foreman_server" -And $items[0].StartsWith("#") -ne 1 ){$my_foreman_server = $items[1].Trim()}
        if ($items[0] -eq "my_domain_name" -And $items[0].StartsWith("#") -ne 1 ){$my_domain_name = $items[1].Trim()}
        if ($items[0] -eq "my_domain_ou_path" -And $items[0].StartsWith("#") -ne 1 ){$my_domain_ou_path = $items[1].Trim()}
        if ($items[0] -eq "my_domain_user" -And $items[0].StartsWith("#") -ne 1 ){$my_domain_user = $items[1].Trim()}
        if ($items[0] -eq "my_domain_user_password" -And $items[0].StartsWith("#") -ne 1 ){$my_domain_user_password = $items[1].Trim()}
        if ($items[0] -eq "choco_extra_source" -And $items[0].StartsWith("#") -ne 1 ){$choco_extra_source = $items[1].Trim()}
        if ($items[0] -eq "choco_extra_source_name" -And $items[0].StartsWith("#") -ne 1 ){$choco_extra_source_name = $items[1].Trim()}
        if ($items[0] -eq "choco_packages" -And $items[0].StartsWith("#") -ne 1 ){$choco_packages = $items[1].Trim()}
        if ($items[0] -eq "jumbo_key_value" -And $items[0].StartsWith("#") -ne 1 ){$jumbo_key_value = $items[1].Trim()}
        if ($items[0] -eq "puppet_agent"-And $items[0].StartsWith("#") -ne 1 ){$puppet_agent = $items[1].Trim()}
        if ($items[0] -eq "quiet_mode" -And $items[0].StartsWith("#") -ne 1){$quiet_mode = $items[1]
                                        [System.Convert]::ToBoolean($quiet_mode)| out-null
                                        }
    }
}

If ($quiet_mode -eq $false ) {
    # Display values
    Write-Host -f green "my_foreman_server      :" -nonewline;Write-Host  -f white $my_foreman_server
    Write-Host -f green "my_domain_name         :" -nonewline;Write-Host  -f white $my_domain_name
    Write-Host -f green "my_domain_ou_path      :" -nonewline;Write-Host  -f white $my_domain_ou_path
    Write-Host -f green "my_domain_user         :" -nonewline;Write-Host  -f white $my_domain_user
    Write-Host -f green "my_domain_user_password:" -nonewline;Write-Host  -f white $my_domain_user_password  
    Write-Host -f green "choco_extra_source_name:" -nonewline;Write-Host  -f white $choco_extra_source_name
    Write-Host -f green "choco_extra_source     :" -nonewline;Write-Host  -f white $choco_extra_source
    Write-Host -f green "choco_packages         :" -nonewline;Write-Host  -f white $choco_packages
    Write-Host -f green "jumbo_key_value        :" -nonewline;Write-Host  -f white $jumbo_key_value
    Write-Host -f green "puppet_agent           :" -nonewline;Write-Host  -f white $puppet_agent   

    $your_choice = ""
        while ($your_choice -notmatch "[y|n]"){
            $your_choice = read-host "Is this correct? (Y/N)"
        }      

    if ($your_choice -eq "n"){
        Write-Output "Exiting now..."
        Exit 0
        }
}
   
# Let's check where is sources/sxs
    $our_disks = (get-psdrive –psprovider filesystem).Root
        foreach ($our_disk in $our_disks) {
                        $testpath=$our_disk+"sources\sxs\"
                        if (Test-Path $testpath){ 
                                Write-Output "Found SXS folder in $our_disk"
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
        else {
            Write-Output "Source of SxS folder could not be found. Not installing .NET Framework 2.0"
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
choco source add -n="$choco_extra_source_name" -s"$choco_extra_source" --priority=10

# Install puppet and configure to access foreman server
$my_foreman_server_parsed = "PUPPET_MASTER_SERVER=$my_foreman_server"
choco install $puppet_agent -ia $($my_foreman_server_parsed) -y --allow-empty-checksums

# Stop Puppet service before name change
Stop-Service puppet -ErrorAction SilentlyContinue
Set-Service -Name puppet -StartupType Automatic -ErrorAction SilentlyContinue

# install extrapackages required (ready to be modified)
choco install $choco_packages -y --allow-empty-checksums

# Ask for name, rename and join domain
If ($quiet_mode -eq $false ) {
    $newcomputername = Read-Host "Please give new name for the computer"
    $cred = Get-Credential
}    
else {
    $cred_pass = ConvertTo-SecureString $my_domain_user_password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -argumentlist ($my_domain_user,$cred_pass)
}

Add-Computer -DomainName $my_domain_name -Credential $cred -OUPath $my_domain_ou_path
Rename-Computer -NewName $newcomputername -DomainCredential $cred -Force -Confirm:$false

#Optional reboot
  If ($quiet_mode -eq $false ) {
      Restart-Computer -Confirm:$true
  }
  else {
      Restart-Computer -Confirm:$false -Force   
  }