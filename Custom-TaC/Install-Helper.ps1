<#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
    .NOTES
#>
if(!(Get-Module AzureADPreview -ListAvailable)) {
    if( Get-Module AzureAD -ListAvailable ) {
        Uninstall-Module AureAD -Force
    }
    Install-Module AzureADPreview -Force -Scope CurrentUser
}
