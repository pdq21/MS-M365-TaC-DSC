<#
	.SYNOPSIS
	AppReg, Connect, Invoke
	Perm Needed
	NewServicePrincipalAppRoleAssignment
	.NOTES
	Connect as GA or Cloud-Application Administrator to register new enterprise app
	Expects CredFiles as CSV w/o Header/TypeInfo: TenantId, ClientAppId, ClientAppSecret
	.LINK
	https://www.wpninjas.eu
#>
[CmdletBinding(SupportsShouldProcess)]
param (
	[Parameter(Mandatory)][string[]]
	[ValidateSet(
		"AzureAD",
		"CloudPrint",
		"InformationProtection",
		"Windows365",
		"Intune",
		"CA",
		"All"
	)]$M365_components,
	[Parameter][string]
	$outPath = ".",
#	[Parameter][string]
#	$outFilePrefix = "",
	[Parameter][string[]]
	[ValidateSet("DOCX","CSV","JSON","All")]
	$outType = "DOCX",
	[Parameter][string]
    	[ValidateSet("env","file","newAppReg")]
	$credType = "env",
	[Parameter][string]
	$credFileCsv = "",
	[Parameter][string]
	[ValidateSet(",",";")]
	$credFileCsvDelim = ",",
	[Parameter][Int32]
	$tokenLtDaysM365App
)

Set-ExecutionPolicy -ExecutionPolicy "Bypass" -Scope "Process"
if(("CA" -inotin $M365_components) -or ($M365_components.Length -gt 1)) {
	Import-Module M365Documentation
}
if("CA" -iin $M365_components) {
	Import-Module IntuneDocumentation
}

$date = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
$outPath = "${outPath}\${date}"
#$outFile = "${outPath}\${outFilePrefix}"

if(!(Test-Path $outPath)) {
	try {
		New-Item -Path $outPath -Type "Directory" -Force | Out-Null
	}
	catch {
		Write-Host "$($Error[0].Category.Reason) $($Error[0].FullyQualifiedErrorId)"
		Write-Host "Exiting..."
		exit
	}
}

#get creds
switch ($credType) {
	"env" {
		$paramM365 = @{
			TenantID = ${env:TenantId}
			ClientID = ${env:clientId}
			ClientSecret = ${env:clientSecret}
		}
	}
	"file" {
		#get csv w/o Header/TypeInfo
		$cf = (Get-Content $credFileCsv).split($credFileCsvDelim)
		$paramM365 = @{
			TenantID = $cf[0]
			ClientID = $cf[1]
			ClientSecret = $cf[2]
		}
	}
	"newAppReg" {
		try {
			$paramM365 = New-M365DocAppRegistration -TokenLifetimeDays $tokenLtDaysM365App
			#New-IntuneDocumentationAppRegistration 
			ConvertTo-Csv $paramM365 -NoTypeInformation | `
				Out-File -FilePath $credFileCsv -Force
		}
		catch {
			Write-Host "$($Error[0].Category.Reason) $($Error[0].FullyQualifiedErrorId)"
		}
	}
	default {
		Write-Host "${credType} not recognized. exiting..."
		exit
	}
}
$paramM365.ClientSecret = ConvertTo-SecureString $paramM365.ClientSecret -Force -AsPlainText

#get config
try {
	if(("CA" -inotin $M365_components) -or ($M365_components.Length -gt 1)) { 
		Connect-M365Doc @paramM365
		$M365doc = Get-M365Doc -Components ($M365_components -replace "CA","")
		$outFile = "${outPath}\M365"
		$outType | ForEach-Object {
			switch ($_) {
				"DOCX" {
					Write-M365DocWord "${outFile}.docx" (Optimize-M365Doc $M365doc)
				}
				"CSV" {
					New-Item -Path "${outPath}\csv" -Type "Directory" -Force | Out-Null
					Write-M365DocCsv "${outPath}\csv" $M365doc
				}
				"JSON" {
					Write-M365DocJson "${outFile}.json" $M365doc
				}
				default {
					Write-Host "${_} not recognized as output filetype. Exiting..."
					exit
				}
			}
		}
	}
	if("CA" -iin $M365_components) {
		if(Get-Module PSWriteWord) {
			#unload module PSWriteWord if loaded
			#Add-WordText function (PSWriteWord) and cmdlet (PSWord) overloaded
			#param -FilePath only in PSWord, named -WordDocument in PSWriteWord
			[Boolean]$modPsWriteWord = $true
			Remove-Module PSWriteWord -Force
			Import-Module PSWord -Force
		}
		$paramCA = @{
			Tenant = $paramM365.TenantID
			ClientId = $paramM365.ClientId
			ClientSecret = $paramM365.ClientSecret
			FullDocumentationPath = "${outPath}\CA.docx"
		}
		#Invoke-IntuneDocumentation @parIntune #contained in M365Docu
		Invoke-ConditionalAccessDocumentation @paramCA
		if($modPsWriteWord) {
			Remove-Module PSWord -Force
			Import-Module PSWriteWord -Force
			Remove-Variable $modPsWriteWord
		}
	}
}
catch {
	Write-Host "$($Error[0].Category.Reason) $($Error[0].FullyQualifiedErrorId)"
	Write-Host "Exiting..."
	exit
}
