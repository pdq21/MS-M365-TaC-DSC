<#
    .SYNOPSIS
    Get information about Tenant-registered apps and Service Principals.
    .DESCRIPTION
    Service Principals:
    - OAuth2PermissionGrant
    Apps:
    - 
    .EXAMPLE
    .NOTES
#>
$outPath = "."

Import-Module AzureADPreview

$date = Get-Date -Format "yyyy-MM-dd"
$time = Get-Date -Format "HH-mm-ss"
#$cred = Get-Credential
$connection = Connect-AzureAD #-Credential $cred

[PSCustomObject]$details = [ordered]@{
    Date = $date
    Time = $time
    TenantId = $connection.TenantId.GUID
    TenantDomain = $connection.TenantDomain
    TenantEnvironment = $connection.Environment.Name.ToString()
    ServicePrincipalApps = @{}
}
$integratedApps = Get-AzureADServicePrincipal -All:$true | Where-Object {
    $_.Tags -eq "WindowsAzureActiveDirectoryIntegratedApp"
}
$integratedApps | ForEach-Object {
    $param = @{
        ObjectId = $_.ObjectId
        All = $true
    }
    $details.ServicePrincipalApps.Add(
        $_.ObjectId,
        [ordered]@{
            ServicePrincipal = $_
            SPMembership = Get-AzureADServicePrincipalMembership @param
            SPObject = Get-AzureADServicePrincipalCreatedObject @param
            SPOauth2Perms = Get-AzureADServicePrincipalOAuth2PermissionGrant @param
            AppRoleAssignedTo = Get-AzureADServiceAppRoleAssignedTo @param
            AppRoleAssignments = Get-AzureADServiceAppRoleAssignment @param
        }
    )
}
$details | ConvertTo-Json | Out-File -FilePath "${outPath}\${date}_${time}_ServicePrincipalApps.json" -Force
