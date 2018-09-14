##############################################################################
## Script from https://gist.github.com/jacobludriks/9ca9ce61de251a5476f1	##
## 	jacobludriks/wsus-update.ps1											##
##############################################################################

Function WSUSUpdate {
	$Criteria = "IsInstalled=0 and Type='Software'"
	$Searcher = New-Object -ComObject Microsoft.Update.Searcher
	try {
		$SearchResult = $Searcher.Search($Criteria).Updates
		if ($SearchResult.Count -eq 0) {
			Write-Output "There are no applicable updates."
			exit
		} 
		else {
			$Session = New-Object -ComObject Microsoft.Update.Session
			$Downloader = $Session.CreateUpdateDownloader()
			$Downloader.Updates = $SearchResult
			$Downloader.Download()
			$Installer = New-Object -ComObject Microsoft.Update.Installer
			$Installer.Updates = $SearchResult
			$Result = $Installer.Install()
		}
	}
	catch {
		Write-Output "There are no applicable updates."
	}
}

$Result = WSUSUpdate

if ($result.resultcode -eq 2) { Restart-Computer }