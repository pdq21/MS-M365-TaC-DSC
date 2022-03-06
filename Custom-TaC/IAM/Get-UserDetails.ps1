<#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
    .NOTES
#>
$filepath = $env:OutPathTaC
$date = Get-Date -Format "yyyy-MM-dd"
$time = Get-Date -Format "HH-mm-ss"

Import-Module AzureADPreview
$connection = Connect-AzureAD

$details = [ordered]@{
    Date = $date
    Time = $time
    TenantDomain = $connection.TenantDomain    
    TenantId = $connection.Tenantid.Guid
    Environment = $connection.Environment.Name.ToString()
    Users = @{}
}
( Get-AzureADUser ) | ForEach-Object {
    Write-Host $_.UserPrincipalName
    $details.Users.$($_.ObjectId) = [ordered]@{
        'UserDetails' = $_
        'Membership' = Get-AzureADUserMembership -ObjectId $_.ObjectId
        'Licenses' = Get-AzureADUserLicenseDetail -ObjectId $_.ObjectId
        'Devices' = Get-AzureADUserRegisteredDevice -ObjectId $_.ObjectId
    }
}

if(!(Test-Path $filepath)) {
    New-Item -Type Directory -Path $filepath -Type Directory `
        -EA SilentlyContinue| Out-Null
}
$details | ConvertTo-Json | Out-File -FilePath "${filepath}\Users_${date}_${time}.json"
