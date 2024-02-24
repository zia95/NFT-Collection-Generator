<#
.SYNOPSIS
    Auto generate config file for the generator
.DESCRIPTION
    Auto generate config file for the generator
.EXAMPLE
    .\Get-NFTGeneratorConfig.ps1 -LayersDirectory ./input/test -OutputConfigFile ./test.json

    name            layers
    ----            ------
    ...........
    ...........
#>
#Requires -Version 6.0
[CmdletBinding()]
param(
    #Directory where all the layers are stored.
    [Parameter(Mandatory=$true)]
    [ValidateScript({(Test-Path $_) -and ((Get-ChildItem $_).Length -ne 0)}, ErrorMessage="Layers directory does not exist or is empty.")]
    [string]$LayersDirectory,
    #Config file to be generated.
    [Parameter(Mandatory=$true)]
    [ValidateScript({-not (Test-Path $_)}, ErrorMessage="Output file already exists.")]
    [string]$OutputConfigFile
)

$LayersDirectory = Resolve-Path $LayersDirectory

function Get-TraitsConfigFromDirectory
{
    param (
        [ValidateNotNullOrEmpty()]
        [string]$LayerDirectory
    )
    $dirlayerconfig = [PSCustomObject]@{
        name = [System.IO.Path]::GetFileName($LayerDirectory)
        traits = [PSCustomObject[]]@()
    }
    $dirlayerconfig.traits = Get-ChildItem $LayerDirectory | ForEach-Object {
        [PSCustomObject]@{
            weight = 1
            sources = @(Resolve-Path -Relative $_)
        }
    }

    return $dirlayerconfig;
}
$config = [PSCustomObject]@{
    name = "newly generated"
    layers = [PSCustomObject[]]@()
}
$config.layers = Get-ChildItem $LayersDirectory | Where-Object PSIsContainer | ForEach-Object {
    Get-TraitsConfigFromDirectory -LayerDirectory $_
}
$config | ConvertTo-Json -Depth 100 >> $OutputConfigFile
return $config;