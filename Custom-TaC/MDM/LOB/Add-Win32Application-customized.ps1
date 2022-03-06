<#
    .SYNOPSIS
    copied from MS LOB
    .DESCRIPTION
    .NOTES
    .LINK
    https://pdq
    .LINK
    https://MS
    .EXAMPLE
    #Simple
    $DetectionRule = New-DetectionRule -MSI -MSIproductCode "{00000000-0000-0000-0000-000000000000}"
    #Default return codes: 0 & 1707 Success, 3010 Soft Reboot, 1641 Hard Reboot, 1618 Retry
    $ReturnCodes = Get-DefaultReturnCodes 
    $param = @{
        SourceFile = "$SourceFile"
        publisher = "Publisher"
        description = "Description"
        detectionRules = $DetectionRule #MSI, FILE, HKLM
        returnCodes = $ReturnCodes
    }
    Upload-Win32Lob @param
    .EXAMPLE
    #Advanced
    $exec = "powershell.exe -File `".\install.ps1`" -executionpolicy Bypass"
    $exec = ${exec} -uninstallCmdLine 'powershell.exe -executionpolicy Bypass `".\install.ps1`"'"
    $param = @{
        SourceFile = "$SourceFile"
        displayName = "Application Name"
        publisher = "Publisher"
        description = "Description"
        detectionRules = $DetectionRule
        returnCodes = $ReturnCodes
        installCmdLine = $exec
        installExperience = "SYSTEM" #USER
    }
    Upload-Win32Lob @param
    .EXAMPLE
    #Multiple detection rules
    $DetectionXML = Get-IntuneWinXML "$SourceFile" -fileName "detection.xml"
    $FileRule = New-DetectionRule -File -Path "C:\Program Files\Application" `
        -FileOrFolderName "application.exe" -FileDetectionType exists `
        -check32BitOn64System False
    $RegistryRule = New-DetectionRule -RegistryDetectionType exists `
        -Registry -RegistryKeyPath "HKEY_LOCAL_MACHINE\SOFTWARE\Program" `
        -check32BitRegOn64System True
    $MSIRule = New-DetectionRule -MSI -MSIproductCode `
        $DetectionXML.ApplicationInfo.MsiInfo.MsiProductCode
    $DetectionRule = @($FileRule,$RegistryRule,$MSIRule)
    .EXAMPLE
    #Multiple custom return codes combined with defaults
    $ReturnCodes = Get-DefaultReturnCodes
    $ReturnCodes += @(
        New-ReturnCode -returnCode 302 -type softReboot
        New-ReturnCode -returnCode 145 -type hardReboot
    )
    .EXAMPLE
    #Multiple custom return codes
    $ReturnCodes = @(
        New-ReturnCode -returnCode 302 -type softReboot
        New-ReturnCode -returnCode 145 -type hardReboot
    )
#>

#TODO

exit
