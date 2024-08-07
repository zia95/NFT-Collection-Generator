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
    [string]$OutputConfigFile,
    #Try to parse trait name from file name. For this to work, make sure trait file names are in right format i.e. <traitname>_<weight>.png
    [Parameter]
    [switch]$TryParseTraitName,
    #Try to parse weight from file name. For this to work, make sure trait file names are in right format i.e. <traitname>_<weight>.png
    [Parameter]
    [switch]$TryParseWeight
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
        $n = [System.IO.Path]::GetFileNameWithoutExtension($_);#default value
        $w = 1;#default value
        if(($TryParseTraitName -or $TryParseWeight) -and $n.Contains('_'))
        {
            $nw = $n.Split('_');
            if($nw.Count == 2)
            {
                if($TryParseTraitName -and -not [string]::IsNullOrWhiteSpace($nw[0]))
                {
                    $n = $nw[0];
                }
                [int]$wref = 0;
                if($TryParseWeight -and -not [string]::IsNullOrWhiteSpace($nw[1]) -and [int]::TryParse($nw[1], [ref]$wref))
                {
                    $w = $wref;
                }
            }
        }
        [PSCustomObject]@{
            name = $n
            weight = $w
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