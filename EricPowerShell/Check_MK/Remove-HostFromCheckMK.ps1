function Remove-HostFromCheckMK {

    <#
    .DESCRIPTION
    Removes a host from CheckMK using WATO API

    .PARAMETER Hostname
    Hostname of server you want to remove from CheckMK

    .PARAMETER Team
    Team that the hostname belongs to.

    .EXAMPLE
    Remove-HostFromCheckMK -Team Infrastructure -Hostname 'someinfrabox'

    .NOTES
    Author: Chris Carmichael
    Date:  12/25/2017

    Features Needed:
    - Error handling if hostname doesn't exist  (how do you know it failed in case of a fat finger)
    ^ I poked around the API for a bit and didn't find an easy way to tell what is in WATO..boo

    #>

    param (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("Infrastructure","Forkner","Sumit")]
        $Team,
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        $Hostname
    )
    
    #Defining the folder names as they are in CheckMK for the URL
    switch ($Team) {

        Infrastructure {
            $Folder = 'infrastructure'
        }        
        Forkner {
            $Folder = 'group_4_-_forkner'
        }
        Sumit {
            $Folder = 'group_3_-_sumit'
        }
    
    }

    #Remove host from WATO
    Invoke-WebRequest -Uri "http://checkmk-tx1/prod/check_mk/wato.py?mode=folder&_username=svc-cmkautomation&_secret=YPXLCLWOCXAQTTVTCDRQfdsakl23432543fdjJKLDSFJ&_do_actions=yes&_do_confirm=yes&_delete_host=$Hostname&_transid=-1&folder=$Folder"

    #Commit your changes to WATO
    Invoke-WebRequest -Uri 'http://checkmk-tx1/prod/check_mk/webapi.py?action=activate_changes&_username=svc-cmkautomation&_secret=YPXLCLWOCXAQTTVTCDRQfdsakl23432543fdjJKLDSFJ&mode=all\'

    Write-Output "$Hostname removed from CheckMK" #presumably
