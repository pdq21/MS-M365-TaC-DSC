<#
	2021-12-23
	https://docs.microsoft.com/en-us/graph/api/serviceprincipal-post-approleassignedt
#>

$modules = @(
	#Thomas Kurth
#	"ModernWorkplaceClientCenter"
#	"ModernAndSecureWorkplace"
	"M365Documentation"
	"IntuneDocumentation"
	#https://www.powershellgallery.com/packages/PSWord
	#https://github.com/guidooliveira/PSWord
	"PSWord"
	#dep M365Doc
	#https://www.powershellgallery.com/packages/PSWriteWord
	#https://github.com/EvotecIT/PSWriteWord
	"PSWriteWord"
	#dep IntuneDoc
	#https://docs.microsoft.com/en-us/graph/overview
	#https://seanmcavinue.net/2020/12/08/connect-to-graph-api-using-powershell-with-delegated-permissions/
	"Microsoft.Graph.Intune"
	#MS Auth Lib
	"MSAL.PS"
	#AppReg
	#"AzureAD" #some new features missing
	"AzureADPreview"
)

$modules | ForEach-Object {
	Write-Host "Trying ${_}..."
	$pkg = Get-Module -ListAvailable -Name ${_}
	if (!${pkg}) {
		Write-Host "${_} not installed. Installing..."
		$pkg = Install-Module ${_} -Force -AllowClobber | Wait-Process
	} <# else {
		$ver = "$($pkg.Version.Major).$($pkg.Version.Minor).$($pkg.Version.Build)"
		Write-Host "${_} already installed as ${ver}. Trying to update..."
		Update-Module -Name ${_} -Force | Wait-Process
	} #>
#TODO error catch, only display new version if successfull
	$ver = "$($pkg.Version.Major).$($pkg.Version.Minor).$($pkg.Version.Build)"
	Write-Host "Version installed: ${ver}"
}


