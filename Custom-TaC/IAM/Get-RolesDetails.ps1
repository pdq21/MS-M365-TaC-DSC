<#
    .SYNOPSIS
    Get M365 roles inside AAD, PIM and Intune, no Azure roles.
    .DESCRIPTION
    .EXAMPLE
    .NOTES
    Intune roles need MS Graph to be admin consented.
    https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/powershell-for-azure-ad-roles
    .LINK
#>

Import-Module AzureADPreview -Force

$filePath = "C:\data\M365\docu-autom-test\CED_Output"
$fileName = "users"

#$AzureAdCred = Get-Credential
$curUser = Connect-AzureAD #-Credential $AzureAdCred

#get data
$users = Get-AzureADUser
$rolesAAD = @((Get-AzureADDirectoryRole),'')
#TODO use ht instead of array of ht?
$rolesAADmembers = @{}
$rolesAAD | ForEach-Object {
    $rolesAADmembers.Add(
        $_.ObjectId,
        (Get-AzureADDirectoryRoleMember -ObjectId $_.ObjectId | `
            Select-Object ObjectId, UserPrincipalName, ServicePrincipalNames)
    )
}
#TODO catch tenant not onboarded to PIM
$PIM = @{
    ProviderId = "aadRoles"
    ResourceId = $curUser.TenantId
}
$rolesPIM = Get-AzureADMSPrivilegedRoleAssignment @PIM
$rolesPIMDef = Get-AzureADMSPrivilegedRoleDefinition @PIM

#parse data
$detailsObj = New-Object -TypeName PSObject -Property @{
    $curUser.TenantDomain = $curUser.TenantId
    'AAD' = @{}
    'PIM' = @{}
    'Intune' = @{}
}
#TODO factor fun GetRoleMember out?
$rolesAAD | ForEach-Object {
    $detailsObj.AAD.Add(
        $_.DisplayName,
        @{
            'ObjectId' = $_.ObjectId
            'Description' = $_.Description
            'Members' = @{}
        }
    )


    
    if ($_ -match 'UserPrincipalName') {
        'UserPrincipalName',
        $_.UserPrincipalName
    } else {
        'ServicePrincipalNames',
        $_.ServicePrincipalNames
    }

}

$members | ForEach-Object {
    @{}.Add(
        'ObjectId',
        $_.ObjectId
    )
    @{}.Add(

    )
}

#TODO catch MethodInvocationException Add() Key ArgumentNullException   
$rolesPIM.RoleDefinitionId | Select-Object -Unique | ForEach-Object {
    $DisplayName = ($rolesPIMDef -match $_).DisplayName
    try {
        $detailsObj.PIM.Add(
            $DisplayName,
            @{
                'ObjectId' = $_.RoleDefinitionId
                'Members' = @{
                    'UserPrincipalName' = $_.UserPrincipalName
                    'ObjectId' = $_ObjectId.ObjectId
                }
            }
        )
    } catch {
        #$_[-1]
    }
    ($rolesPIM -match $_) | ForEach-Object {
        try {
            $detailsObj.PIM.$DisplayName.'Members'.Add(
                ($users -match $_.SubjectId).DisplayName,
                $_
            )
        } catch {
            #$_[-1]
        }
    }
}

$date = Get-Date -Format "yyyy-MM-dd"
$time = Get-Date -Format "HH-mm-ss"
$of = "${filePath}\${fileName}_${date}_${time}"
$detailsObj | ConvertTo-Json -Compress -Depth 10 | Out-File -FilePath "${of}.json" -Force
