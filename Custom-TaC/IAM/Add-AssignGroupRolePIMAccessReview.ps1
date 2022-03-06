<#
    .SYNOPSIS
    Simple workflow to create role-assigned and PIM-onboarded groups with Access Reviews.
    PIM-onboarding is needed for permanent eligibility and JIT-activation.
    AAD does only provide 
    .DESCRIPTION
    Workflow
    - Create an AAD-Group
    - Assign users
    - Onboard AAD-Group into PIM, adjust Owner/Member settings
    - Assign AAD-Role to group, adjust role settings
    - Create Access Review in AAD or PIM, adjust AR settings
    .EXAMPLE
    .NOTES
    Admin consent may be needed.
    Users need P2-License in order to use PIM.
    https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-create-azure-ad-roles-and-resource-roles-review
    https://docs.microsoft.com/en-us/azure/active-directory/roles/groups-create-eligible
    https://docs.microsoft.com/en-us/azure/active-directory/roles/groups-assign-role
#>

#TODO

exit


$groups = Get-AzureADMSGroup

$groupsNoSecEnabled = $groups | Where-Object securityenabled -eq $false
$groupsRoleAssignable = $groups | Where-Object IsAssignableToRole -eq $true
