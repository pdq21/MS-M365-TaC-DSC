<#
	.SYNOPSIS
	Export all available M365DSC workloads. 
	.NOTES
	Gets path to export to and creds from env.
#>
$date = (Get-Date).ToString("yyyy-MM-dd_HH-mm")
$param = @{
	Path = "${env:M365DSC_path}\${date}"
	Workloads = @("AAD","INTUNE","SC","OD","O365","PLANNER","PP","TEAMS","EXO","SPO")
	Credential = [PSCredential]::new(
		${env:M365DSC_user}, `
		$( ${env:M365DSC_pw} | ConvertTo-SecureString -AsPlainText -Force )
	)
}

Set-ExecutionPolicy "RemoteSigned" -Scope Process
Import-Module "Microsoft365DSC"

$param.Workloads | ForEach-Object {
	$splat = @{
		Credential = ${global:param}.Credential
		Workload = $_
		Path = ${global:param}.Path
		FileName = "${_}.ps1"
        Mode = "Full"
		GenerateInfo = $true
	}
	Export-M365DSCConfiguration @splat
}
