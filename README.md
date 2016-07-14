<h1> Powershell script for default settings in new Hyper-V 2012 R2 instalations

## Maintainer
* Marcin Bojko - marcinbojko.pl(at)gmail.com

This script adds required Windows features and firewall settings as well.
Also, install Chocolatey provider, installs doublecmd and sysinternals package, installs and cofigures Puppet Agent for WIndows (3.x)

## Changelog

* 2016-07-13 version 1.13
	* switched to variables in some code parts

* 2016-06-21 version 1.12
	* added values for JumboPacket and VMQ disable
	* improved logic for adding computer to domain

* 2016-06-10 version 1.10
	* switched to Powershell v3 for whole script
	* switched from *.cmd extension to *.ps1
	
* 2016-06-06 version 1.09
	* Syntax checking for Group Rules Firewall Install
	* switch to Powershell for the rest of the script

* 2016-05-25 version 1.08
	* Switching to PowerShell for firewall features.
	* Install chocolatey at the end


## Prerequisites
* at least one configured network interface (IP/Subnet/GW/DNS)
* installation source left on (usb/dvd) - required for winsxs folder
	
## Usage
powershell .\default_set.ps1

## Optional Items to disable
* Enable/Disable JUmbo frames (may be skipped)
* Install chocolatey provider
* Install additional packages (doublecmd, sysinternals)