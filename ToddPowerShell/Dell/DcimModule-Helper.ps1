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
	Module containing helper functions for the Dcim libray of cmdlets.
.DESCRIPTION
	This is a module, source or import this file to use.
.LINK
	More information about this package:
	http://en.community.dell.com/techcenter/systems-management/w/wiki/3649.psdcim.aspx
.LINK
	To understand functionalities, refer to the Profile Specification.
	http://en.community.dell.com/techcenter/systems-management/w/wiki/1839.aspx
.NOTES
	Author: Chris A. Poblete
#>

#=====================================================================
# Global Variables  
#=====================================================================

$Script:Version = '1.0.0.0000'

$Script:uris = @{ dmtf="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2"; `
				  dell="http://schemas.dell.com/wbem/wscim/1/cim-schema/2"; `
                  cql="http://schemas.dmtf.org/wbem/cql/1/dsp0202.pdf" }
				  
$Script:namespace = @{ w="http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd"; `
                       a="http://schemas.xmlsoap.org/ws/2004/08/addressing" }

$LogNone=0
$LogFatal=1
$LogError=2
$LogWarn=3
$LogInfo=4
$LogDebug=5

#=====================================================================
# Functions  
#=====================================================================

Function Get-ScriptName {  
    <#
    .SYNOPSIS
		Extracts the script name.
    .DESCRIPTION
		Extracts the script file name without extention.
    .EXAMPLE
		$someVar = Get-ScriptName
    .NOTES
		Author: Axel Kara, axel.kara@gmx.de, Jay Perusse
    #>

    if (!$scriptName) {
        $tmp = $MyInvocation.ScriptName.Substring($MyInvocation.ScriptName.LastIndexOf('\') + 1)  
        $scriptName = $tmp.Substring(0,$tmp.Length - 4)  
    }    
    $scriptName
}  

#=====================================================================
Function Write-Log {  
    <# 
    .SYNOPSIS  
		Creates a log entry  
    .DESCRIPTION  
		By default a time stamp will be logged too. This can be  
		disabled with the -LogTime $false parameter  
    .EXAMPLE  
		Write-Log -Msg 'Log entry created successfull.' [-LogTime $false]  
    .NOTES  
		Author: Axel Kara, axel.kara@gmx.de, Jay Perusse, Chris A. Poblete
    #>

    [CmdletBinding()]
    param (            
        [alias('LL')]
        [Parameter(mandatory=$true,Position=0,HelpMessage="Log level: 0=none,1=fatal,2=error,3=warning,4=info,5=debug")]
        [int]$logLevel = 1,
		
        [alias('MG')]
        [Parameter(mandatory=$true,Position=1,HelpMessage="Message string")]
        [string]$Msg,            

        [alias('LT')]
        [Parameter(mandatory=$false,Position=2,HelpMessage="Include log time prefix. Default is `$True")]
        [System.Boolean]$LogTime=$true            
    ) 
     
    if ($LogTime) { 
        # set your date
        $logDate = Get-Date -Format MM.dd.yyyy-HH:mm:ss
        # set the string you are logging. skeleton structure by log level
        $stringToLog = $logDate + "  " + $loglevel + " " * $logLevel + $Msg 
    }  
    else{  
        # set the string you are logging without date and log level
        $stringToLog = $Msg 
    }     

    # have we defined verbosity? 
    # if verbosity is not defined, we set it here as 0
    if ($Global:Verbosity -eq $null) {$Global:Verbosity = $LogNone}
    
    # now we use the Logfile
    # if the log level is lower or equal to than the verbosity, we also spit to screen
    if ($logLevel -le $Global:Verbosity) { Write-Host $stringToLog }

    # finally, stick this in the log
	if ($Global:LogFile -and (Test-Path $Global:LogFile)) {
		Add-Content -Path $Global:LogFile -Value $stringToLog   
	}
}  
  
#=====================================================================
Function Dcutil-ShowCredentialFile {
    <#
    .SYNOPSIS
		Show contents of credential file.
    .DESCRIPTION
		Given credential file, display the contents.
    .EXAMPLE
		$someVar = Dcutil-ShowCredentialFile -filepath "c:\192.168.1.112.cred"
    .NOTES
		Author: Chris A. Poblete
    #>
	
    [CmdletBinding()]
    param (            
        [alias('PATHFILENAME')]
        [Parameter(mandatory=$true,Position=0,HelpMessage="The complete path to credential file.")]
        [string]$filepath
    )
	
    if (!(Test-Path -Path $filepath -PathType Leaf)) {
        Dcutil-ExportCredential (Get-Credential) $filepath
    }
    $cred = Import-Clixml $filepath
    $cred.Password = $cred.Password | ConvertTo-SecureString
    $Credential = New-Object System.Management.Automation.PsCredential($cred.UserName, $cred.Password)
    Return $Credential
}

#=====================================================================
Function Dcutil-ExportCredential {
    <#
    .SYNOPSIS
    Export user name and password to credential file.

    .DESCRIPTION
    You will be prompted to enter user name and password and save it to a credential file. Password will be encrypted.
    
    .EXAMPLE
    $someVar = Dcutil-ExportCredential -filepath "c:\192.168.1.112.cred"

    .NOTES
    Author: Chris A. Poblete
    #>
	
    [CmdletBinding()]
    param (            
        [alias('PATHFILENAME')]
        [Parameter(mandatory=$true,Position=0,HelpMessage="The complete path to credential file.")]
        [string]$filepath            
    )
	
	Write-Log $LogInfo "Dcutil-ExportCredential()"
    $cred = (Get-Credential) | Select-Object *
    $cred.password = $cred.Password | ConvertFrom-SecureString
    $cred | Export-Clixml $filepath
	Return
}

#=====================================================================
Function Dcutil-ImportCredential {
    <#
    .SYNOPSIS
	Import user name and password from credential file.

    .DESCRIPTION
	Given a credential file, extract to a PsCredential object. Password is encrypted.
    
    .EXAMPLE
    $someVar = Dcutil-ImportCredential -filepath "c:\192.168.1.112.cred"

    .NOTES
    Author: Chris A. Poblete
    #>
	
    [CmdletBinding()]
    param (            
        [alias('PATHFILENAME')]
        [Parameter(mandatory=$true,Position=0,HelpMessage="The complete path to credential file.")]
        [string]$filepath            
    )
	
	Write-Log $LogInfo "Dcutil-ImportCredential()"
    $cred = Import-Clixml $filepath
    $cred.Password = $cred.Password | ConvertTo-SecureString
    $Credential = New-Object System.Management.Automation.PsCredential($cred.UserName, $cred.Password)
	Return $Credential
}

#=====================================================================
Function Dcim-NewSession {  
    <#
    .SYNOPSIS
    Initialize new Dcim session.

    .DESCRIPTION
    Initialize new Dcim session. Call this first before calling other Dcim Functions.
    
    .EXAMPLE
    $someVar = Dcim-NewSession mycred.xml 192.168.0.119

    .NOTES
    Author: Chris A. Poblete
    #>
	
    [CmdletBinding()]
    param (            
        [alias('NAMEORFILE')]
        [Parameter(mandatory=$true,Position=0,HelpMessage="User name or Credential file to use for authenticating WSMAN connection.")]
        [string]$userorcredfile,            

        [alias('IPADDRESS')]
        [Parameter(mandatory=$true,Position=1,HelpMessage="The IP address of the WSMAN endpoint/node.")]
        [string]$ipaddr,
		
        [alias('PORTNUM')]
        [Parameter(mandatory=$false,HelpMessage="WSMAN connection port number, defaults to 443.")]
        [int]$port=443,
		
        [alias('OPERATIONTIME')]
        [Parameter(mandatory=$false,HelpMessage="WSMAN operation timeout in milliseconds, defaults to 60 seconds.")]
        [int]$optime=60000
    )
	
	Write-Log $LogInfo "Dcim-NewSession()"
	$dcimsession = New-Object PSObject
	
	# connection credential
	if (Test-Path $userorcredfile) {
		$Credential = Dcutil-ImportCredential -filepath $userorcredfile
	} else {
		$Credential = Get-Credential $userorcredfile
	}
	$dcimsession | Add-Member NoteProperty Credential $Credential
	
	# create the session object
	$wsmansession = New-WSManSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -OperationTimeout $optime
	$dcimsession | Add-Member NoteProperty SessionOption $wsmansession
	
	# connection address and port
	$dcimsession | Add-Member NoteProperty IPAddress $ipaddr
	$dcimsession | Add-Member NoteProperty PortNum $port
	
	Return $dcimsession
}  

#=====================================================================
Function Dcim-Enumerate {  
    <#
    .SYNOPSIS
    Performs WSMAN Enumerate, simplified helper wrapper.

    .DESCRIPTION
    Performs WSMAN Enumerate, simplified helper wrapper.
    
    .EXAMPLE
    $someVar = DCIM-Enumerate $mysession CIM_ComputerSystem

    .NOTES
    Author: Chris A. Poblete
    #>
	
    [CmdletBinding()]
    param (            
        [alias('DCIMSESSION')]
        [Parameter(mandatory=$true,Position=0,HelpMessage="The session object, use Dcim-NewSession() to get this.")]
        [PSObject]$dcimsess,
		
        [alias('CLASSNAME')]
        [Parameter(mandatory=$true,Position=1,HelpMessage="CIM class name.")]
        [string]$class,

        [alias('CQLFILTER')]
        [Parameter(mandatory=$false,HelpMessage="CQL filter string.")]
        [string]$filter,
		
        [alias('URI')]
        [Parameter(mandatory=$false,HelpMessage="URI prefix code, [dmtf,dell] defaults to dmtf.")]
        [string][ValidateSet("dmtf", "dell")]$uriprefix = "dmtf",
		
        [alias('EPROUTPUT')]
        [Parameter(mandatory=$false,HelpMessage="Request Endpoint Reference (EPR) response, default to `$False.")]
        [Switch]$epr
    )

	Write-Log $LogInfo "Dcim-Enumerate()"
	
	$uriprefixstr = $Script:uris.Item($uriprefix)
	
	$wsmanargs = @{
		ComputerName = $dcimsess.IPAddress
		Port = $dcimsess.PortNum
		UseSSL = $true
		SessionOption = $dcimsess.SessionOption
		Authentication = "basic"
		Credential = $dcimsess.Credential
		ResourceURI = "$uriprefixstr/$class"
		ReturnType = "Object"
	}

	if ($epr) {
		$wsmanargs.ReturnType = "ObjectAndEPR"
	}
	if ($filter) {
		$wsmanargs.Dialect = $Script:uris.cql
		$wsmanargs.Filter = $filter
	}
	
	$lresult = Get-WSManInstance -Enumerate @wsmanargs
	Write-Log $LogDebug ("Dcim-Enumerate`n" + $lresult.OuterXml)
	
	Return $lresult
}

#=====================================================================
Function Dcim-Invoke {  
    <#
    .SYNOPSIS
    Performs WSMAN Invoke, simplified helper wrapper.

    .DESCRIPTION
    Performs WSMAN Invoke, simplified helper wrapper.
    
    .EXAMPLE
    $someVar = DCIM-Invoke $mysession

    .NOTES
    Author: Chris A. Poblete
    #>
	
    [CmdletBinding()]
    param (            
        [alias('DCIMSESSION')]
        [Parameter(mandatory=$true,Position=0,HelpMessage="The session object, use Dcim-NewSession() to get this.")]
        [PSObject]$dcimsess,
		
        [alias('ABSURI')]
        [Parameter(mandatory=$true,Position=1,HelpMessage="Complete instance URI.")]
        [string]$resourceuri,

        [alias('METHODNAME')]
        [Parameter(mandatory=$true,Position=2,HelpMessage="Method name.")]
        [string]$action,
		
        [alias('ARGFILE')]
        [Parameter(mandatory=$false,HelpMessage="Complete path filename containing method arguments.")]
        [string]$filepath,
		
        [alias('ARGLIST')]
        [Parameter(mandatory=$false,HelpMessage="Hash list of method arguments.")]
        [hashtable]$valueset
    )

	Write-Log $LogInfo "Dcim-Invoke()"	
	
	$wsmanargs = @{
		ComputerName = $dcimsess.IPAddress
		Port = $dcimsess.PortNum
		UseSSL = $true
		SessionOption = $dcimsess.SessionOption
		Authentication = "basic"
		Credential = $dcimsess.Credential
		ResourceURI = $resourceuri
		Action = $action
	}
	
	if ($filepath -and (Test-Path $filepath)) { 
		$wsmanargs.FilePath = $filepath 
	}
	if ($valueset) { 
		$wsmanargs.ValueSet = $valueset 
	}
	
	$lresult = Invoke-WSManAction @wsmanargs
	Write-Log $LogDebug ("Dcim-Invoke`n" + $lresult.OuterXml)
	
	Return $lresult
}

#=====================================================================
Function Dcim-Get {  
    <#
    .SYNOPSIS
    Performs WSMAN Get, simplified helper wrapper.

    .DESCRIPTION
    Performs WSMAN Get, simplified helper wrapper.
    
    .EXAMPLE
    $someVar = DCIM-Get $mysession

    .NOTES
    Author: Chris A. Poblete
    #>
	
    [CmdletBinding()]
    param (            
        [alias('DCIMSESSION')]
        [Parameter(mandatory=$true,Position=0,HelpMessage="The session object, use Dcim-NewSession() to get this.")]
        [PSObject]$dcimsess,
		
        [alias('CLASSNAME')]
        [Parameter(mandatory=$true,Position=1,HelpMessage="CIM class name.")]
        [string]$class,

        [alias('HASHLIST')]
        [Parameter(mandatory=$true,Position=2,HelpMessage="Complete instance URI.")]
        [hashtable]$selectorset,
		
        [alias('URI')]
        [Parameter(mandatory=$false,HelpMessage="URI prefix code, [dmtf,dell] defaults to dmtf.")]
        [string][ValidateSet("dmtf","dell")]$uriprefix = "dmtf"		
    )

	Write-Log $LogInfo "Dcim-Get()"
	
	$uriprefixstr = $Script:uris.Item($uriprefix)

	$wsmanargs = @{
		ComputerName = $dcimsess.IPAddress
		Port = $dcimsess.PortNum
		UseSSL = $true
		SessionOption = $dcimsess.SessionOption
		Authentication = "basic"
		Credential = $dcimsess.Credential
		ResourceURI = "$uriprefixstr/$class"
		SelectorSet = $selectorset
	}
	
	$lresult = Get-WSManInstance @wsmanargs
	Write-Log $LogDebug ("Dcim-Get`n" + $lresult.OuterXml)
	
	Return $lresult
}

#=====================================================================
Function Dcutil-EprGetResourceURI {
    <#
    .SYNOPSIS
    Get the ResourceURI XML object from EPR response.

    .DESCRIPTION
    Get the ResourceURI XML object from EPR response (XML object).
    
    .EXAMPLE
    $someVar = Dcutil-EprGetResourceURI $eprxmlobj

    .NOTES
    Author: Chris A. Poblete
    #>
	
    [CmdletBinding()]
    param (            
        [alias('XMLOBJ')]
        [Parameter(mandatory=$true,Position=0,HelpMessage="The XML object, XML contains EPR.")]
        [PSObject]$eprxmlobj
    )
	
	$lr = Select-Xml -Xml $eprxmlobj -XPath "//w:ResourceURI/text()" -Namespace $Script:namespace | Select -Expand Node | Select -Expand Value
	Return $lr
}

#=====================================================================
Function Dcutil-EprGetRefParamXMLStr {
    <#
    .SYNOPSIS
    Get the ReferenceParameters XML string from EPR response.

    .DESCRIPTION
    Get the ReferenceParameters XML string from EPR response (XML object).
    
    .EXAMPLE
    $someVar = Dcutil-EprGetRefParamXMLStr $eprxmlobj

    .NOTES
    Author: Chris A. Poblete
    #>
	
    [CmdletBinding()]
    param (            
        [alias('XMLOBJ')]
        [Parameter(mandatory=$true,Position=0,HelpMessage="The XML object, XML contains EPR.")]
        [PSObject]$eprxmlobj
    )
	
	$lr = Select-Xml -Xml $eprxmlobj -XPath "//a:ReferenceParameters" -Namespace $Script:namespace | Select -Expand Node
	Return $lr.OuterXML
}

#=====================================================================
Function Dcutil-EprGetAddressXMLString {
    <#
    .SYNOPSIS
    Get the Address XML string from EPR response.

    .DESCRIPTION
    Get the Address XML string from EPR response (XML object).
    
    .EXAMPLE
    $someVar = Dcutil-EprGetAddressXMLString $eprxmlobj

    .NOTES
    Author: Chris A. Poblete
    #>
	
    [CmdletBinding()]
    param (            
        [alias('XMLOBJ')]
        [Parameter(mandatory=$true,Position=0,HelpMessage="The XML object, XML contains EPR.")]
        [PSObject]$eprxmlobj
    )
	
	$lr = Select-Xml -Xml $eprxmlobj -XPath "//a:Address" -Namespace $Script:namespace | Select -Expand Node
	Return $lr.OuterXML
}

#=====================================================================
Function Dcutil-EprGetEPRXMLString {
    <#
    .SYNOPSIS
    Get the EPR XML string from EPR response.

    .DESCRIPTION
    Get the EPR XML string from EPR response (XML object).
    
    .EXAMPLE
    $someVar = Dcutil-EprGetEPRXMLString $eprxmlobj

    .NOTES
    Author: Chris A. Poblete
    #>
	
    [CmdletBinding()]
    param (            
        [alias('XMLOBJ')]
        [Parameter(mandatory=$true,Position=0,HelpMessage="The XML object, XML contains EPR.")]
        [PSObject]$eprxmlobj
    )
	
	$lr = Dcutil-EprGetAddressXMLString $eprxmlobj
	$lr += Dcutil-EprGetRefParamXMLStr $eprxmlobj
	Return $lr
}

#=====================================================================
Function Dcutil-EprGetSelectorValue {
    <#
    .SYNOPSIS
    Get Selector value string from EPR response.

    .DESCRIPTION
    Get Selector value string from EPR response (XML object).
    
    .EXAMPLE
    $someVar = Dcutil-EprGetSelectorValue $eprxmlobj

    .NOTES
    Author: Chris A. Poblete
    #>
	
    [CmdletBinding()]
    param (            
        [alias('XMLOBJ')]
        [Parameter(mandatory=$true,Position=0,HelpMessage="The XML object, XML contains EPR.")]
        [PSObject]$eprxmlobj,
		
        [alias('NAME')]
        [Parameter(mandatory=$true,Position=1,HelpMessage="The Selector node name to search for.")]
        [PSObject]$selectorname
    )
	
	$lr = Select-Xml -Xml $eprxmlobj -XPath "//w:Selector[@Name='$selectorname']" -Namespace $Script:namespace | Select -Expand Node
	Return $lr.FirstChild.Data
}

#=====================================================================
Function Dcutil-EprSelectorsToStringHash {
    <#
    .SYNOPSIS
    Get Selectors as string hash from EPR response.

    .DESCRIPTION
    Get Selectors as string hash from EPR response (XML object).
    
    .EXAMPLE
    $someVar = Dcutil-EprSelectorsToStringHash $eprxmlobj

    .NOTES
    Author: Chris A. Poblete
    #>
	
    [CmdletBinding()]
    param (            
        [alias('XMLOBJ')]
        [Parameter(mandatory=$true,Position=0,HelpMessage="The XML object, XML contains EPR.")]
        [PSObject]$eprxmlobj
    )
	
	$lempty = $true
	$lresult = "@{"
	
	$lr = Select-Xml -Xml $eprxmlobj -XPath "//w:SelectorSet/*" -Namespace $Script:namespace | Select -Expand Node
	$lenum = $lr.GetEnumerator()
	$lenum.Reset()
	
	while ($lenum.MoveNext()) {
		$item = $lenum.Current
		$lresult += $item.GetAttribute("Name") + '="' + $item.InnerText + '";'
		Write-Log $LogDebug ("SelectorsToStringHash: " + $lresult)
		$lempty = $false
	}
	
	if ($lempty -eq $false) {
		$lresult = $lresult.substring(0, $lresult.Length - 1)
	}
	$lresult += "}"
	
	Return $lresult
}

#=====================================================================
Function Dcutil-EprGetInstanceURIString {
    <#
    .SYNOPSIS
    Get Selectors as string from EPR response.

    .DESCRIPTION
    Get Selectors as string from EPR response (XML object).
    
    .EXAMPLE
    $someVar = Dcutil-EprGetInstanceURIString $eprxmlobj

    .NOTES
    Author: Chris A. Poblete
    #>
	
    [CmdletBinding()]
    param (            
        [alias('XMLOBJ')]
        [Parameter(mandatory=$true,Position=0)]
        [PSObject]$eprxmlobj,
		
        [alias('RURI')]
        [Parameter(mandatory=$false)]
        [string]$resourceuri
    )
	
	[string]$lresult = $resourceuri
	if (!$resourceuri) {
		[string]$lresult = Dcutil-EprGetResourceURI -eprxmlobj $eprxmlobj
	}
	$lresult += "?"
	$lempty = $true
	
	$lr = Select-Xml -Xml $eprxmlobj -XPath "//w:SelectorSet/*" -Namespace $Script:namespace | Select -Expand Node
	$lenum = $lr.GetEnumerator()
	$lenum.Reset()
	
	while ($lenum.MoveNext()) {
		$item = $lenum.Current
		$lresult += $item.GetAttribute("Name") + '=' + $item.InnerText + '+'
		Write-Log $LogDebug ("SelectorsToStringHash: " + $lresult)
		$lempty = $false
	}
	
	if ($lempty -eq $false) {
		$lresult = $lresult.substring(0, $lresult.Length - 1)
	}
	
	Return $lresult
}

#=====================================================================
Function Dcutil-EprResourceURIStringBugFix {
    <#
    .SYNOPSIS
    Correct ResourceURI string from bug in enumerate with filter.

    .DESCRIPTION
    A bug in WSMAN service where enumerating a base class with EPR and
	filter to return a specific instance returns a response where the
	ResourceURI contains the base class and not the derived class. When
	used with subsequent call to a get or method invoke operation, it
	fails. Correct this using the CreationClassName if exist in the 
	class and the value is correct.
    
    .EXAMPLE
    $someVar = Dcutil-EprResourceURIStringBugFix $eprxmlobj

    .NOTES
    Author: Chris A. Poblete
    #>
    [CmdletBinding()]
    param (            
        [alias('RURI')]
        [Parameter(mandatory=$true,Position=0,HelpMessage="The ResourceURI string to fix.")]
        [string]$resourceuri,
		
        [alias('BNAME')]
        [Parameter(mandatory=$true,Position=1,HelpMessage="The original base class name.")]
        [string]$baseclassname,
		
        [alias('XMLOBJ')]
        [Parameter(mandatory=$true,Position=2,HelpMessage="The XML object, XML contains EPR..")]
        [PSObject]$eprxmlobj
    )
	
	$ccn = Dcutil-EprGetSelectorValue $eprxmlobj "CreationClassName"
	$lfrom = $Script:uris.dmtf + "/$baseclassname"
	$lto = $Script:uris.dell + "/${ccn}"
	$correctedstr = $resourceuri | %{$_ -replace $lfrom,$lto}
	
	Return $correctedstr
}

#=====================================================================
Function Dcutil-NamespacesGetInstanceURIString {
    <#
    .SYNOPSIS
    Get the instance URI string from namespace.

    .DESCRIPTION
    Instance namespace declaration is not always at the top node. Search the XML namespaces for the instance URI.
    
    .EXAMPLE
    $sysviewnamespace = Dcutil-NamespacesGetInstanceURIString $xmlobj "DCIM_SystemView"

    .NOTES
    Author: Chris A. Poblete
    #>
	
    [CmdletBinding()]
    param (            
        [alias('XML')]
        [Parameter(mandatory=$true,Position=0,HelpMessage="The XML object to search.")]
        [PSObject]$xmlobj,
		
        [alias('NAME')]
        [Parameter(mandatory=$true,Position=1,HelpMessage="The instance class name.")]
        [string]$classname
    )
	
	$iuristr = $null
	$namespaces = Select-Xml -Xml $xmlobj -XPath "descendant::*/namespace::*"
	for ($ii = 0; $ii -lt $namespaces.Count; $ii++) {
	   $item = $namespaces.Get($ii)
	   #Write-Host $item.Node.LocalName " = " $item.Node.Value
	   if ($item.Node.Value.ToLower().Contains($classname.ToLower())) {
	      $iuristr = $item.Node.Value
		  break
	   }
	}
	
	Return $iuristr
}

#=====================================================================
# End of file
#=====================================================================
