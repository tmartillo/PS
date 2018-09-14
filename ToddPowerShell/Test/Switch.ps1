$mailRequester = read-host -prompt "Enter the email address to send the account info to"
function Validate-Email ([string]$mailRequester) 
while{ 
  return $mailRequester -match "^(?("")("".+?""@)|(([0-9a-zA-Z]((\.(?!\.))|[-!#\$%&'\*\+/=\?\^`\{\}\|~\w])*)(?<=[0-9a-zA-Z])@))(?(\[)(\[(\d{1,3}\.){3}\d{1,3}\])|(([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,6}))$" 
write-host "not I think this is valid"}  {write-host "whaaaaaaat"}