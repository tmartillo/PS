if(!$script:ServiceNowCreds){
    $script:ServiceNowCreds = Get-Credential
}

$uri = 'https://atlascopco.service-now.com/api/now/table/incident?sysparm_limit=10'

$Body = @{
    'sysparm_query' = 'ORDERBYDESCopened_at'
}
$result = Invoke-RestMethod -Uri $uri -Credential $script:ServiceNowCreds -Body $Body -ContentType "application/json" 
$result.result | select opened_at, number, short_description