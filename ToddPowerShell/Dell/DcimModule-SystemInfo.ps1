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
	Module containing cmdlets for DCIM System Info profile functionality.
.DESCRIPTION
	This is a module, source or import this file to use.
	Using the WSMAN interface, retrieves data and performs actions
	as it pertains to the DCIM System Info profile functionality. 
.LINK
	More information about this package:
	http://en.community.dell.com/techcenter/systems-management/w/wiki/3649.psdcim.aspx
.LINK
	Refer to DCIM System Info profile specification at:
	http://en.community.dell.com/techcenter/systems-management/w/wiki/1839.aspx
.NOTES
	Author: Chris A. Poblete
#>

#=====================================================================
# Dependencies
#=====================================================================

Function _Get-ScriptDirectory {
	$Invocation = (Get-Variable MyInvocation -Scope 1).Value
	Split-Path $Invocation.MyCommand.Path
}
Import-Module (Join-Path (_Get-ScriptDirectory) DcimModule-Helper.ps1)

#=====================================================================
# Global Variables  
#=====================================================================

$Script:Version = '1.0.0.0000'

if (!$Global:Verbosity) {
	[int]$Global:Verbosity = $LogError
}
if (!$Global:LogFile) {
	[string]$Global:LogFile = "dcimlog.txt"
}

#=====================================================================
# Functions  
#=====================================================================

Function Dcim-GetModel {
    <#
    .SYNOPSIS
		Retrieves system model string.
    .DESCRIPTION
		Using the WSMAN interface, retrieves the system model string.  
	.LINK
		Refer to DCIM System Info profile specification at:
		http://en.community.dell.com/techcenter/systems-management/w/wiki/1839.aspx
    .EXAMPLE
		$rsp = Dcim-GetModel $mysession
		
		Description
		-----------
		TBD.
		
		Requires a session object, an example is 
		C:\PS>$sess = Dcim-NewSession mycred.xml 192.168.138.46
		
		Credential file may be generated with 
		C:\PS>Dcutil-ExportCredential mycred.xml
    .NOTES
        Author: Chris A. Poblete
    #>
	
    [CmdletBinding()]
    param (            
        [alias('DCIMSESSION')]
        [Parameter(mandatory=$true,Position=0,HelpMessage="The session object, use Dcim-NewSession() to get this.")]
        [PSObject]$dcimsess = $null
    )
	
	Write-Log $LogInfo "Dcim-GetTime()"
	[System.IO.Directory]::SetCurrentDirectory((get-location))	
	
	$result = Dcim-Enumerate $dcimsess DCIM_SystemView -filter "select Model from DCIM_SystemView"
	$ns = Dcutil-NamespacesGetInstanceURIString $result "DCIM_SystemView"
	$model = Select-Xml -Xml $result -XPath "//x:Model" -Namespace @{x=$ns}
	if ($model) {
		Return $model.toString()
	}
	
	Return $null
} # Function Dcim-GetModel

#=====================================================================
# End of file
#=====================================================================
