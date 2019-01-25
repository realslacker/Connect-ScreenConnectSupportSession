<#PSScriptInfo

.VERSION 2019.01.24

.GUID 130cca50-bf3e-4798-9a1f-0bff0045e0e9

.AUTHOR Shannon Graybrook

.COMPANYNAME Brooksworks

.COPYRIGHT 2019 (c) Brooksworks

.TAGS ScreenConnect

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


.PRIVATEDATA 

#>

<# 
.DESCRIPTION 
 Connect to a ScreenConnect remote support session from PowerShell.
 
.PARAMETER ScreenConnectUri
 URI for ScreenConnect instance
 
.PARAMETER SessionName
 What should your session be named
 
.PARAMETER ScreenConnectPath
 Path to ScreenConnect files
#>
param(

    [Parameter(Mandatory=$true)]
    [ValidatePattern('(?# must include http/https )^https?://.+')]
    [ValidateNotNullOrEmpty()]
    [string]
    $ScreenConnectUri,

    [ValidateNotNullOrEmpty()]
    [string]
    $SessionName = "PowerShell Session - $env:COMPUTERNAME",

    [ValidateNotNullOrEmpty()]
    [string]
    $ScreenConnectPath

)

$ErrorActionPreference = 'Stop'

if ( $PSVersionTable.PSVersion.Major -lt 3 ) {

    throw 'Minimum supported version of PowerShell is 3.0'

}

if ( -not $ScreenConnectPath ) {

    $ScreenConnectPath = Split-Path (Get-Variable MyInvocation -Scope Script).Value.Mycommand.Definition -Parent

}

$ConnectionParams = @{
    y = 'Guest'
    h = $null
    p = $null
    s = $null
    k = $null
    i = $SessionName
}

$InvokeWebRequestSplat = @{
    Uri             = '{0}/Script.ashx' -f $ScreenConnectUri.Trim('/')
    UseBasicParsing = $true
}
$ScreenConnectJS = Invoke-WebRequest @InvokeWebRequestSplat

if ( $ScreenConnectJS.RawContent -match '"h":"(?<h>[^"]+)","p":(?<p>\d+),"k":"(?<k>[^"]+)"' ) {

    $ConnectionParams.h = $Matches.h
    $ConnectionParams.p = $Matches.p
    $ConnectionParams.k = [uri]::EscapeDataString($Matches.k)

} else {

    Write-Error 'Could not parse connection params!'

}

$InvokeRestMethodSplat = @{
    Method = 'Post'
    Uri    = '{0}/App_Extensions/2d4e908b-8471-431d-b4e0-2390f43bfe67/Service.ashx/CreateGuestSupportSession' -f $ScreenConnectUri.Trim('/')
    Body   = (ConvertTo-Json @($SessionName))
}
$ConnectionParams.s = Invoke-RestMethod @InvokeRestMethodSplat

$ScreenConnectArguments = ( $ConnectionParams.Keys | %{ '{0}={1}' -f $_, $ConnectionParams.$_ } ) -join '&' -replace '^', '"?' -replace '$', '"'

$ScreenConnectExe = Join-Path $ScreenConnectPath 'ScreenConnect.WindowsClient.exe'

if ( Test-Path -Path $ScreenConnectExe ) {

    Start-Process -FilePath $ScreenConnectExe -ArgumentList $ScreenConnectArguments

} else {

    Write-Error 'Could not locate ScreenConnect.WindowsClient.exe'

}
