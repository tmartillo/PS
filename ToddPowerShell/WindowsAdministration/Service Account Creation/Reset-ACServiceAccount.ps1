Function Reset-ACServiceAccount {
<#
		.SYNOPSIS
			Cmdlt to Reset Atlas Copco Service Accounts

		.DESCRIPTION
			The Reset-ACServiceAccount Cmdlt allows you to reset Services accounts.
			The account information will be sent to an Atlas Copco contact you provide with in the mandatory parameter.
			The Recipient will receive two mails : one for accountname and random ID and one for password and the same ID, 
			random ID is create in case more accounts are created and sent to the same person.
			

		.PARAMETER  Account
			Account name to perform a password reset on.

		.PARAMETER  PasswordLength
		    Specifies the length used for a random generated password. This parameter is not required for a new account,
			the default value is set to 16 digits.

		.PARAMETER  ExcludeChar
			Excludes charachters from the generated password.

		.PARAMETER  mailRequester		
			MailRequester refers to Atlas Copco contact person that will receive the mail with accountname and password.
			You can specify multiple mail address.
			
				-MailRequester "Mail1@domain.com","Mail2@domain.com"
			
		.PARAMETER  Credential	
			Specifies the user account credentials to use to perform this task. 
			The default credentials are the credentials of the currently logged on user unless the cmdlet is run from an Active Directory PowerShell provider drive. 
			If the cmdlet is run from such a provider drive, the account associated with the drive is the default.
			
			To specify this parameter, you can type a user name, such as "User1" or "Domain01\User01" or you can specify a PSCredential object. 
		If you specify a user name for this parameter, the cmdlet prompts for a password. 

		You can also create a PSCredential object by using a script or by using the Get-Credential cmdlet. 
		You can then set the Credential parameter to the PSCredential object The following example shows how to create credentials.
		$AdminCredentials = Get-Credential "Domain01\User01"

		The following shows how to set the Credential parameter to these credentials.
			-Credential $AdminCredentials

		If the acting credentials do not have directory-level permission to perform the task, Active Directory PowerShell returns a terminating error.
			
		.EXAMPLE
			PS C:\> Reset-ACServiceAccount
			cmdlet Reset-ACServiceAccount at command pipeline position 1
			Supply values for the following parameters:
			Account:
			mailRequester[0]: 
			
			Reset Service Account with prompted parameters
			
		.EXAMPLE
			PS C:\> Reset-ACServiceAccount -Account "MyServiceAccount" -MailRequester "Mail1@Domain.com"
			
			Reset Service Account with defined parameters
			
		.EXAMPLE
			PS C:\> Reset-ACServiceAccount -Account "MyServiceAccount" -MailRequester "Mail1@Domain.com" -$PasswordLength 20
			
			Reset Service Account with defined parameters and specify password length to make stronger password.
			
		.INPUTS
			string
			string
			int
			string[]
			System.Management.Automation.CredentialAttribute()

		.OUTPUTS
			Boolean
			Mail to MailRequester(s)

		.NOTES
			Additional information about the function go here.

		.LINK
			#NA
	#>	
	[cmdletbinding()]
	param(
		[Parameter(Position=1,mandatory=$true)]
        [string] $Account,
		
		[Parameter(Position=2,mandatory=$true)]
		[string[]] $mailRequester,
		
		[Parameter(Position=3)]
		[ValidateRange(8,128)]
        [int] $PasswordLength = 16,
		
		[Parameter(Position=4)]
		[String[]]$ExcludeChar,
		
		[Parameter(Position=5)]
		[System.Management.Automation.CredentialAttribute()]$Credential
    )

        Function Get-Seed{
            # Generate a seed for randomization
            $RandomBytes = New-Object -TypeName 'System.Byte[]' 4
            $Random = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider'
            $Random.GetBytes($RandomBytes)
            [BitConverter]::ToUInt32($RandomBytes, 0)
        }

	function New-SWRandomPassword {
   
    [CmdletBinding(DefaultParameterSetName='FixedLength',ConfirmImpact='None')]
    [OutputType([String])]
    Param
    (
        # Specifies minimum password length
        [Parameter(Mandatory=$false,ParameterSetName='RandomLength')]
        [ValidateScript({$_ -gt 0})]
        [Alias('Min')] 
        [int]$MinPasswordLength = 16,
        
        # Specifies maximum password length
        [Parameter(Mandatory=$false,
                   ParameterSetName='RandomLength')]
        [ValidateScript({
                if($_ -ge $MinPasswordLength){$true}
                else{Throw 'Max value cannot be lesser than min value.'}})]
        [Alias('Max')]
        [int]$MaxPasswordLength = 32,

        # Specifies a fixed password length
        [Parameter(Mandatory=$false,
                   ParameterSetName='FixedLength')]
        [ValidateRange(1,2147483647)]
        [int]$PasswordLength = 16,
        
        # Specifies an array of strings containing charactergroups from which the password will be generated.
        # At least one char from each group (string) will be used.
		[String[]]$InputStrings = @('abcdefghijkmnpqrstuvwxyz', 'ABCEFGHJKLMNPQRSTUVWXYZ', '123456789', '!"#%&'),
		
		
		[String[]]$ExcludeChar,
		        

        # Specifies a string containing a character group from which the first character in the password will be generated.
        # Useful for systems which requires first char in password to be alphabetic.
        [String] $FirstChar,
        
        # Specifies number of passwords to generate.
        [ValidateRange(1,2147483647)]
        [int]$Count = 1
    )
    Begin {
        Function Get-Seed{
            # Generate a seed for randomization
            $RandomBytes = New-Object -TypeName 'System.Byte[]' 4
            $Random = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider'
            $Random.GetBytes($RandomBytes)
            [BitConverter]::ToUInt32($RandomBytes, 0)
        }
		
		foreach($item in $ExcludeChar){
			$InputStrings = $InputStrings.replace($item,"")
		}
    }
    Process {
        For($iteration = 1;$iteration -le $Count; $iteration++){
            $Password = @{}
            # Create char arrays containing groups of possible chars
            [char[][]]$CharGroups = $InputStrings

            # Create char array containing all chars
            $AllChars = $CharGroups | ForEach-Object {[Char[]]$_}

            # Set password length
            if($PSCmdlet.ParameterSetName -eq 'RandomLength')
            {
                if($MinPasswordLength -eq $MaxPasswordLength) {
                    # If password length is set, use set length
                    $PasswordLength = $MinPasswordLength
                }
                else {
                    # Otherwise randomize password length
                    $PasswordLength = ((Get-Seed) % ($MaxPasswordLength + 1 - $MinPasswordLength)) + $MinPasswordLength
                }
            }

            # If FirstChar is defined, randomize first char in password from that string.
            if($PSBoundParameters.ContainsKey('FirstChar')){
                $Password.Add(0,$FirstChar[((Get-Seed) % $FirstChar.Length)])
            }
            # Randomize one char from each group
            Foreach($Group in $CharGroups) {
                if($Password.Count -lt $PasswordLength) {
                    $Index = Get-Seed
                    While ($Password.ContainsKey($Index)){
                        $Index = Get-Seed                        
                    }
                    $Password.Add($Index,$Group[((Get-Seed) % $Group.Count)])
                }
            }

            # Fill out with chars from $AllChars
            for($i=$Password.Count;$i -lt $PasswordLength;$i++) {
                $Index = Get-Seed
                While ($Password.ContainsKey($Index)){
                    $Index = Get-Seed                        
                }
                $Password.Add($Index,$AllChars[((Get-Seed) % $AllChars.Count)])
			}
            Write-Output -InputObject $(-join ($Password.GetEnumerator() | Sort-Object -Property Name | Select-Object -ExpandProperty Value))
        }
    }
}

		if($ExcludeChar -eq $null){
			$Password = New-SWRandomPassword -PasswordLength $PasswordLength
		}else{
			$Password = New-SWRandomPassword -ExcludeChar $ExcludeChar -PasswordLength $PasswordLength
		}		
		
	try{
	
	Set-ADAccountPassword $Account -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force) -Credential $Credential

		$ID = $null
		$ID = Get-Seed
		$subject = "Service Account Creation - " + $Description 
		$bodyUI =
		"Dear, `r
		Newly Created Service Account `r
		" +	$Description + "`r`r
		Creation ID : " + $ID + " `r`r
		Account: " + $Account + "`r 
		---------------------`r"
		
		$bodyPW =
		"Dear, `r
		Newly Created Service Account `r
		" +	$Description + "`r`r
		Creation ID : " + $ID + " `r`r
		Password: " + $Password + "`r 
		---------------------`r"

		Foreach($MailID in $mailRequester){
			send-MailMessage -To $MailID  -From "NoReplySecurity@atlascopco.com" -Subject $subject -Body $bodyUI -SmtpServer "smtp.emea.group.atlascopco.com"
			send-MailMessage -To $MailID  -From "NoReplySecurity@atlascopco.com" -Subject $subject -Body $bodyPw -SmtpServer "smtp.emea.group.atlascopco.com"
		}
	$result = $true
	}catch{
		$_.exception
		$result = $false
	}
	
	return  $result
}