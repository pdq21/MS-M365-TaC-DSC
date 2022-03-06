<#
    .SYNOPSIS
    This function is used to authenticate with the Graph API REST interface
    .DESCRIPTION
    The function authenticate with the Graph API Interface with the tenant name
    .EXAMPLE
    Get-AuthToken
    Authenticates you with the Graph API interface
    .NOTES
    NAME: Get-AuthToken
#>
[CmdletBinding()]
param (
    #open GUI online to generate List of granular options to export components and exit
    [Parameter()][switch]
    $showGuiOnline,
    #show all available ressources
    [Parameter()][switch]
    $showAvailRes,
    #test for proper MS Graph Permissions, returns Hashtable, expected Names: ReadPermissions, UpdatePermissions
    [Parameter()][switch]
    $showFullPermList
)

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Import-Module Microsoft365DSC

if($showGuiOnline) {
    Export-M365DSCConfiguration -LaunchWebUI
    break
}
if($showAvailRes) {
    Get-M365DSCAllResources
    break
}
if($showFullPermList) {
    Get-M365DSCCompiledPermissionList -ResourceNameList (Get-M365DSCAllResources)
    break
}