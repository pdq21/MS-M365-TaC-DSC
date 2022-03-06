<#
    .SYNOPSIS
    Device Lifecycle Management, disable and delete inactive devices
    .LINK
    https://docs.microsoft.com/de-de/azure/active-directory/devices/manage-stale-devices
#>

#TODO

exit


$dt = (Get-Date).AddDays(-90)
Get-AzureADDevice -All:$true | Select-Object -Property AccountEnabled, DeviceId, DeviceOSType, `
    DeviceOSVersion, DisplayName, DeviceTrustType, ApproximateLastLogonTimestamp | `
    Export-Csv devicelist-summary.csv -NoTypeInformation

Get-AzureADDevice -All:$true | Where-Object {
    $_.ApproximateLastLogonTimeStamp -le $dt
} | Select-Object -Property AccountEnabled, DeviceId, DeviceOSType, DeviceOSVersion, `
    DisplayName, DeviceTrustType, ApproximateLastLogonTimestamp | `
    Export-Csv devicelist-olderthan-90days-summary.csv -NoTypeInformation

$dt = (Get-Date).AddDays(-90)
Get-AzureADDevice -All:$true | Where-Object {
    $_.ApproximateLastLogonTimeStamp -le $dt
} | Set-AzureADDevice -AccountEnabled $false

$dt = (Get-Date).AddDays(-120)
$state = $false
Get-AzureADDevice -All:$true | Where-Object {
    ($_.ApproximateLastLogonTimeStamp -le $dt) -and `
    ($_.AccountEnabled -le $state)
} | Remove-AzureADDevice