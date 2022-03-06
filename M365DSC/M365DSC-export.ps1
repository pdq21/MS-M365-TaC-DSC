<#
    .SYNOPSIS
    This cmdlet is a wrapper for Export-M365DSC
    They call it "Configuration-as-Code for the Cloud"
    .DESCRIPTION
    Expects modules (M365DSC v1.22.202.1, Feb 2022)
    "SC","PP","PLANNER","OD","INTUNE","AAD","EXO","SPO","O365","TEAMS"
    xor Components. For list of Components see:

    Does not install or update any dependencies. Use instead:
    > Install-Module -Name Microsoft365DSC -Force
    > Update-M365DSCDependencies
    > Get-Module Microsoft365DSC -ListAvailable | select ModuleBase, Version
    > Set-M365DSCTelemetryOption -Enabled $False
    .EXAMPLE
    .NOTES
    Prereq    
    - 5.1 <= PS  <= 7.1
    - Microsoft Graph Permissions
    - Permissions that may be required:
        - Global Administrator
        - Global Reader
        -  Conditional Access Administrator
        - Devices Admin
        - Security Reader
        - Security Administrator
    - Authentification may fail if SSPR is activated but not fullfilled
    - possible error if required scopes are missing in the token
    
    Modules Covered (workloads)
    AAD, Intune, O365, OD, EXO, SPO
    Teams: Skype for Business, Teams
    PowerApps, Planner, PnP (PP)
    SC:  Security&Compliance Center
    Hint: Workload SPO takes very long

    Components:
    https://export.microsoft365dsc.com/
    > Export-M365DSCConfiguration -LaunchWebUI

    MS Graph App-Reg:
    Global Admin, App Admininistrator, Cloud App Admininistrator
    
    M365 DSC
    https://microsoft365dsc.com/
    https://github.com/microsoft/Microsoft365DSC
    Extract: ReverseDSC to export snapshot of config
    Monitor: drift, fixing, logging, notification
    Asses: against known good, discrepency reports, validate config


    TODO
    asked for 'Destination Path:' after 'Extracting [AADTokenLifetimePolicy]'
    Export-M365 creates log inside script folder, not log folder
#>
[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)][string]
    $outFilePath,
    [Parameter(Mandatory)][string]
    $outFileNamePrefix,
    [Parameter()][string[]]
    [ValidateSet("AAD","SPO","EXO","INTUNE","SC","OD","O365","PLANNER","PP","TEAMS","ALL")]
    $workloads = "ALL",
    [Parameter()][string[]]
    $components,
    [Parameter()][string]
    $credsFilePath,
    [Parameter()][switch]
    $outLog
)

$date = (get-date).ToString("yyyy-MM-dd_HH-mm")

function ExportDscCustom {
    param (
        $workloads, $components,
        $outFp, $outFn,
        $outLog
    )
    $logDsc = Export-M365DSCConfiguration -Credential $Credential `
        -Workloads ${workloads} -Components ${components} `
        -Path "${outFp}" -FileName "${outFn}" `
        -Mode "Full" -GenerateInfo $true
    if($outLog) {
        $logDsc | Out-File -FilePath "${outFp}\${outFn}.log" `
            -Append -Force
    }
}

#modules
#test for necessary modules and select the newest
#TODO use Where-Object or foreach-operator
@("AzureADPreview","AzureAD") | ForEach-Object {
    Write-Host "Looking for installed AAD modules..." -f Yellow
}{
    $mod = Get-Module -Name $_ -ListAvailable
    if($mod) {
        if($mod.count -gt 1) {
            $ver = ($mod | Select-Object Version | Sort-Object)[-1]
            $mod = $mod | Where-Object {
                ($_.version -eq $ver.Version) | Select-Object -Unique
            }
        }
        Write-Host "Using ${mod}." -f Green
        Import-Module -Name "${mod}" -Force
        #TODO break
        #break and continue behave differently in ForEach-Object and foreach-Operator
        #break exits script when called from within ForEach-Object cmdlet
        $mod = -1
    }
}{  
    if($mod -eq -1){
        Write-Host "No AAD modules installed." -f Red
        Write-Host "Run 'Install-Module <AzureADPreview|AzureAD>' from an elevated prompt." -f Yellow
    }
}

Set-ExecutionPolicy "RemoteSigned" -Scope Process
Import-Module "Microsoft365DSC"

#creds
#there may be several popups for credentials despite credentials provided here
#password needs to be of type 'System.Security.SecureString'
#TODO Test-Path earlier, e.g. inside Param-Block?
$msg = "Credentials for MS Graph and M365DSC-App. Admin consent may be needed."
if ($credsFilePath -and (Test-Path $credsFilePath)) {
    Write-Host "Using Credentials from creds file." -f Yellow
   #TODO import csv, json or line-sep?
   #TODO test for SecString
} elseif (!${env:M365DSCuser} -or !${env:M365DSCpw}) {
    Write-Host "Using Credentials from user input." -f Yellow
    $Credential = Get-Credential -Message $msg
    ${env:M365DSCuser} =  $Credential.UserName
    ${env:M365DSCpw} = $Credential.Password 
} else {
    Write-Host "Using Credentials from env." -f Yellow
    #TODO change ugly workaround for PSCredantial with SecureString
    #https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/add-credentials-to-powershell-functions 
    $Credential = [PSCredential]::new(${env:M365DSCuser}, `
        $(${env:M365DSCpw} | ConvertTo-SecureString -AsPlainText -Force))
}

#app permissions
$perms = Get-M365DSCCompiledPermissionList -ResourceNameList (Get-M365DSCAllResources)
if($perms.ReadPermissions) {
    $logDsc = "Read Permissions found. Continuing..."
    Write-Host $logDsc -f Green
} else {
    $logDsc = "No Read Permissions found."
    Write-Host $logDsc
    $logDsc = "${date}`n${logDsc}"
    $logDsc = "Trying to update admin consent and read permissions..."
    try {
        $perms = Update-M365DSCAllowedGraphScopes -Type "Read" `
            -ResourceNameList (Get-M365DSCAllResources)
    } catch  {
        Write-Host $perms
        #TODO outLog before exiting
        exit
    }
}
if($outLog) {
    $logDsc | Out-File -FilePath "${outFilePath}\${outFileNamePrefix}_${date}.log" `
        -Append -Force
}

#path
$outFpFull = "${outFilePath}\${date}"
if(!(Test-Path $outFpFull)) {
    New-Item -Path $outFilePath -Name "${date}" `
        -ItemType Directory -Force | Out-Null
}

#output
#TODO pretify wild loop
$param = @{
    outFp = $outFpFull
    outLog = $outLog
}
#TODO get validate set
if($workloads -icontains "All") {
    $workloads = $workloads.ValidateSet[0..$($workloads.ValidateSet.Length-2)]
}
@($workloads, $components) | ForEach-Object {
    if ($_ -iin $workloads.ValidateSet) {
        $param.workloads = $_
        $param.components = ''
    } else {
        $param.workloads = ''
        $param.components = $_
    }
        $param.outFn = "${outFileNamePrefix}_${_}"
        $param.psobject.properties.keys | ForEach-Object {
        Write-Host $_.name
    }
    ExportDscCustom @param
}

#cleanup
