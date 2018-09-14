# ###########################################################################
# Copyright (c) 2011, Dell Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of the Dell, Inc. nor the names of its contributors
#      may be used to endorse or promote products derived from this software
#      without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL Dell, Inc. BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# ###########################################################################

<#
.SYNOPSIS
	Retrieves management service processor current time.
.DESCRIPTION
	Using the WSMAN interface, retrieves the management service  
	processor current time through the DCIM_TimeService class instance. 
.LINK
	To understand functionalities, refer to the Profile Specification.
	http://en.community.dell.com/techcenter/systems-management/w/wiki/1839.aspx
.LINK
	More information about this package:
	http://en.community.dell.com/techcenter/systems-management/w/wiki/3649.psdcim.aspx
.EXAMPLE
	powershell dcim-getmodel.ps1 .\credfile.xml 192.168.0.111
	Example given a credential file.
.EXAMPLE
	powershell dcim-getmodel.ps1 admin 192.168.0.111
	Example given a user name, you will be prompted for password.
.NOTES
	Author: Chris A. Poblete
#>

param(
	[Parameter(mandatory=$true,Position=0,HelpMessage="User name or credential file.")]
	[string]$UsernameOrCredfile,
	
	[Parameter(mandatory=$true,Position=1,HelpMessage="The IP address of WSMAN target.")]
	[string]$IPAddress	
)

#=====================================================================
# Dependencies
#=====================================================================

Function _Get-ScriptDirectory {
	$Invocation = (Get-Variable MyInvocation -Scope 1).Value
	Split-Path $Invocation.MyCommand.Path
}

$dep1 = Join-Path (_Get-ScriptDirectory) DcimModule-SystemInfo.ps1
Import-Module $dep1

#=====================================================================
# Global Variables  
#=====================================================================

[string]$Global:LogFile = "mylog.txt"

[int]$Global:Verbosity = $LogError
if ($PSBoundParameters.ContainsKey('Verbose')) {
	[int]$Global:Verbosity = $LogInfo
}
if ($PSBoundParameters.ContainsKey('Debug')) {
	[int]$Global:Verbosity = $LogDebug
}

#=====================================================================
# main  
#=====================================================================

$mysess = Dcim-NewSession $UsernameOrCredfile $IPAddress 
$model = $null
if ($mysess) {
    try {
		Dcim-GetModel $mysess
	} catch {
		#$_ | fl *
		Write-Host "NOTE: Check the IP address you provided is valid. Refer to documentation for more info."
	}
}

Return

#=====================================================================
# End of file
#=====================================================================
