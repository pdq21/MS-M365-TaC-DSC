<#
    .SYNOPSIS
    View MFA enrollment state of users.
    .LINK
    Setup for users
    http://aka.ms/mfasetup
    AAD Blade
    https://portal.azure.com/#blade/Microsoft_AAD_IAM/AuthMethodsOverviewBlade
    MS Graph
    https://docs.microsoft.com/en-us/graph/api/resources/credentialuserregistrationdetails
    MS Identity Score
    https://aka.ms/ADIdentitySecureScore
    MFA userstatus
    https://morgantechspace.com/2018/06/find-and-list-mfa-enabled-status-office-365-users-powershell.html
#>

#TODO

exit


#TODO  msol obsolete, use successor
Install-Module MSOnline 
Connect-MsolService

Get-MsolUser -All | Select-Object @{
    N='UserPrincipalName';
    E={$_.UserPrincipalName}
}, `
@{
    N='MFA Status';
    E={
        if ($.StrongAuthenticationRequirements.State){$.StrongAuthenticationRequirements.State}
        else {"Disabled"}
    }
}, `
@{
    N='MFA Methods';
    E={$_.StrongAuthenticationMethods.methodtype}
} | Export-Csv -Path c:\MFA_Report.csv # -NoTypeInformation

