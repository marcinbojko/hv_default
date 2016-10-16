# Powershell script for default settings in new Hyper-V 2012 R2/2016 instalations

## Author

* Marcin Bojko - marcinbojko.pl(at)gmail.com

## Features

This script adds required Windows features and firewall settings as well.
Also, install Chocolatey provider, installs doublecmd and sysinternals package, installs and cofigures Puppet Agent for WIndows (3.x or 4.x)

## Changelog

### 2016-10-16 version 1.18

* added storing variables in hv_default.txt file
* added `quiet_mode` variable for 'in script' processing
* fixed error with $choco_extra_source_name variable being not parsed for `choco source` part
* rename script `default_set.ps1` to `hv_default.ps1`

### 2016-10-13 version 1.17

* checked with official Hyper-V 2016 versions

### 2016-10-11 version 1.16

* added powershell (5.0) to the list of installed packages
* added variable for puppet package name (Puppet3 or Puppet4) for chocolatey
* added '--allow-empty-checksums' for Chocolatey packages install
* fixed bug in parsing PUPPET_MASTER_SERVER variable

### 2016-09-27 version 1.15

* changed filtering of network interfaces to exclude microsoft virtual network interfaces

### 2016-08-25 version 1.14

* added features for chocolatey due to changes in 0.10.0
* first test with Hyper-V 2016 TP5

### 2016-07-13 version 1.13

* switched to variables in some code parts

### 2016-06-21 version 1.12

* added values for JumboPacket and VMQ disable
* improved logic for adding computer to domain

### 2016-06-10 version 1.10

* switched to Powershell v3 for whole script
* switched from *.cmd extension to *.ps1

### 2016-06-06 version 1.09

* Syntax checking for Group Rules Firewall Install
* switch to Powershell for the rest of the script

### 2016-05-25 version 1.08

* Switching to PowerShell for firewall features.
* Install chocolatey at the end

## Prerequisites

* at least one configured network interface (IP/Subnet/GW/DNS)
* installation source left on (usb/dvd) - required for winsxs folder

## Usage

```powershell
powershell .\hv_default.ps1
```

### Params file

If script can find file `hv_default.txt` all parameters can be read from file, overwriting default values.
Separator is set on " = ". If you want to skip line that start with `#`

```ini
my_foreman_server = test.test.com
choco_packages = doublecmd;visualstudiocode;powershell
my_domain_name = domain.test
my_domain_ou_path = OU=Test,DC=dc,DC=example,DC=test
choco_extra_source = https://www.myget.org/F/public-choco2
choco_extra_source_name = test
jumbo_key_value = 6000
puppet_agent = puppet
quiet_mode = true
```
