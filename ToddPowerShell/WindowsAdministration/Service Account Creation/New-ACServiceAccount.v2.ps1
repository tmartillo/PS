#Gather information required to create the account

#Get the FAM Code and test that its 3 digits long
	$Division = Read-Host -Prompt "Enter the FAM code"
	while ($Division.length -ne 3) {
		Write-Output "Please enter a 3 character FAM code."
		$Division = Read-Host "Re-enter FAM code"
	}
#Get the application name. This will fill by in the account name. Ex... SSIapplication_svc	
	$Application = Read-Host -Prompt "Enter the Application (one word no spaces)"

#Get the environment Type and test that its valid.
	$Environment = read-host -Prompt "Enter the Environment Type (4 Options: DEV,STG,PRD,TST)"
	while ($Environment.length -ne 3) {
		Write-Output "Please enter either DEV STG PRD or TST"
		$Environment = Read-Host "Re-enter the environment type"
	}

#Get the Description that will show up on the AD Account	
	$Description = read-host -Prompt "Enter the Description"
	
#This is the default OU where the account will be created

	$OULoc = read-host -Prompt "The default OU for service accounts is: 
	OU=Service Accounts,OU=Admin users,OU=SSI,OU=Group,DC=nasa,DC=group,DC=atlascopco,DC=com
	
Would you like to input a different location? (yes / no)"
	if ($OULoc -match "no") {
		Write-Output "Creating account in OU=Service Accounts,OU=Admin users,OU=SSI,OU=Group,DC=nasa,DC=group,DC=atlascopco,DC=com"
		$OrganizationalUnit = "OU=Service Accounts,OU=Admin users,OU=SSI,OU=Group,DC=nasa,DC=group,DC=atlascopco,DC=com"
	}
	else {$OrganizationalUnit = read-host -Prompt "Enter the new location"}
	while ($OrganizationalUnit.length -eq 0) 
		{Write-Output "Location cannot be blank"
		$OrganizationalUnit = Read-Host "Enter the new location"
	}
	
	
	$PasswordLength = 16

#Get the email address where the info will be sent
	$mailRequester = read-host -prompt "Enter the email address to send the account info to"

	$ExcludeChar = " "

	Function New-SWRandomPassword {
   
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

	Function Get-Seed {
            # Generate a seed for randomization
            $RandomBytes = New-Object -TypeName 'System.Byte[]' 4
            $Random = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider'
            $Random.GetBytes($RandomBytes)
            [BitConverter]::ToUInt32($RandomBytes, 0)
        }
		
		if($ExcludeChar -eq $null){
			$Password = New-SWRandomPassword -PasswordLength $PasswordLength
		}else{
			$Password = New-SWRandomPassword -ExcludeChar $ExcludeChar -PasswordLength $PasswordLength
		}		
		
	try{
	
		$Environment = $Environment.ToUpper()
		$Division = $Division.ToUpper()
		
		$AccountName = $Division+$Application + $Environment +"_svc"
		$UPN = $AccountName + "@" + (Get-ADDomain).dnsroot
		
		if($Credential -ne $null){
			New-ADUser -Description $Description -AccountPassword (ConvertTo-SecureString -AsPlainText $Password -Force) -UserPrincipalName $UPN -PasswordNeverExpires $true -Name $AccountName -SamAccountName $AccountName -CannotChangePassword $true -Enabled $true -DisplayName $AccountName -Path $OrganizationalUnit -Credential $Credential		
		}else{
			New-ADUser -Description $Description -AccountPassword (ConvertTo-SecureString -AsPlainText $Password -Force) -UserPrincipalName $UPN -PasswordNeverExpires $true -Name $AccountName -SamAccountName $AccountName -CannotChangePassword $true -Enabled $true -DisplayName $AccountName -Path $OrganizationalUnit
		}

		$ID = $null
		$ID = Get-Seed
		#Mail Credentials
		$subject = "Service Account Creation - " + $Description 
		$bodyUI =
		"Dear, `r
		Newly Created Service Account `r
		" +	$Description + "`r`r
		Creation ID : " + $ID + " `r`r
		Account: " + $AccountName + "`r 
		---------------------`r"
		
		$bodyPW =
		"Dear, `r
		Newly Created Service Account `r
		" +	$Description + "`r`r
		Creation ID : " + $ID + " `r`r
		Password: " + $Password + "`r 
		---------------------`r"

		Foreach($MailID in $mailRequester){
			send-MailMessage -To $MailID  -From "NoReplySecurity@atlascopco.com" -Subject $subject -Body $bodyUI -SmtpServer "smtp.nasa.group.atlascopco.com"
			send-MailMessage -To $MailID  -From "NoReplySecurity@atlascopco.com" -Subject $subject -Body $bodyPw -SmtpServer "smtp.nasa.group.atlascopco.com"
		}
		$result = $true
	}catch{
		$_.exception
		$result = $false
	}
	if($result -match "False"){
		Write-Host "
		FAILED, invalid input, please try again"}
	else {write-host "
	Success, Sending account info to $mailRequester"}
	
	return  $result
