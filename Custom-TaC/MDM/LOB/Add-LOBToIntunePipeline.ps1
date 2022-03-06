<#
    .SYNOPSIS
    Generates .intunewin from WIN32-Apps and Param-Json and uploads the packages to specified tenant. 
    .DESCRIPTION
    .EXAMPLE
    #Invoking pipeline with splatting:
    $param = @{    
        pathToInstallerFiles            = ".\installer"
        pathToMSWin32ContentPrepTool    = "."
        pathToMSPSLOB_Application       = "."
        pathToIntunePkgParamJson        = "."
        filenameIntunePkgParamJson      = "Win32InstallParams.Json"
        outputPathIntunePkgs            = ".\pkgs"
    }
    Intune-LOB-Pipeline.ps1 @param
    .EXAMPLE
    #Json with parameters for MS Win32 Content Prep Tool and MS Win32_LOB_Application_Add.ps1:
    {
        "Setup_CODESYSV35SP11.exe":  {
            "detection":  "MSI",
            "install":  "/s /v\"/qb /quiet /passive\"",
            "uninstall":  "msiexec /x{627EBCBD-71C2-4FDE-9BEA-3AF7F03FBE10} /qb /passive /quiet"
        }
    }
    .NOTES
    useDebug
        If not set, quite mode is applied.
    MS Win32 Content Prep Tool
        IntuneWinAppUtil.exe -c <source_folder> -s <source_setup_file> -o <output_folder> <-a> <catalog_folder> <-q>
        ZIP
        https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/heads/master.zip
        Source
        https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/releases/latest
    MS Win32_LOB_Application_Add.ps1 
        README.md: "The following script sample provides the ability to upload a Win32 application to the Intune Service."
    TODO
        error handling, logging
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)][string]
    $pathToInstallerFiles,
    [Parameter(Mandatory)][string]
    $pathToMSWin32ContentPrepTool,
    [Parameter(Mandatory)][string]
    $pathToMSPSLOB_Application,
    [Parameter(Mandatory)][string]
    $pathToIntunePkgParamJson,
    [Parameter(Mandatory)][string]
    $filenameIntunePkgParamJson,
    [Parameter(Mandatory)][string]
    $outputPathIntunePkgs,
    [Parameter()][string]
    $credsFilePath,
    [Parameter()][switch]
    $outLog,
    [Parameter()][switch]
    $useDebug
)
$MSWin32CPTexe = "IntuneWinAppUtil.exe"
$MSLOBAppPS1 = "Win32_Application_Add_customized.ps1"

$date = Get-Date -Format "yyyy-MM-dd"
$time = Get-Date -Format "HH-mm-ss"

$paths = @{
    Installer = $pathToInstallerFiles
    CPT = "${pathToMSWin32ContentPrepTool}\${MSWin32CPTexe}"
    LOB = "${pathToMSPSLOB_Application}\${MSLOBAppPS1}"
    JSON = "${pathToIntunePkgParamJson}\${filenameIntunePkgParamJson}"
}

#basic path checking
Write-Host "${date} ${time}" -f Yellow
$paths.Values | ForEach-Object {
    if(!(Test-Path $_)) {
        Write-Host "BAD - ${_} not found. Exting without action..." -f Red
        exit
    }
    else {
        Write-Host "OK - ${_} found." -f Green
    }
}

#workload
$params = Get-Content $paths.JSON | ConvertFrom-Json 
$params.psobject.properties.name | ForEach-Object {
    if(Test-Path "$($paths.Installer)\${_}") {
        Write-Host "Packing ${_}..." -f Yellow
        $argList = "-c `"$($paths.Installer)`" -s `"${_}`" -o `"$($outputPathIntunePkgs)`""
        if($useDebug) {
            $proc = "${env:windir}\System32\cmd.exe"
            $argList = "/k echo ${_} && echo ${argList} && `"$($paths.CPT)`" ${argList}"
            $arglist = "${argList} && pause && exit /B %ERRORLEVEL%"
            Write-Host $argList
        } else {
            $proc = $paths.CPT
            $argList = "${argList} -q"
        }
        $startParam = @{
            FilePath = $proc
            ArgumentList = $argList
            WindowStyle = "Minimized"
        }
        Start-Process @startParam -JobName "hihi"
        #upload to Intune
<#         $intune = @{
            SourceFile = ".intunewin"
            Publisher = ""
            Description = ""
            DetectionRules = ""
            ReturnCodes = ""
        }
        Start-Process $paths.LOB #>
    } else {
        Write-Host "BAD - ${_} not found. Skipping..." -f RED
    }
}