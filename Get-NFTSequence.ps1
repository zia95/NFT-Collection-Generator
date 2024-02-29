<#
.SYNOPSIS
    Generate nft sequences file which then can be used by the nftmerger to generate nfts and the metadata.
.DESCRIPTION
    Generate nft sequences file which then can be used by the nftmerger to generate nfts and the metadata.
.EXAMPLE
    To get a sequence:
    .\Get-NFTSequence.ps1 -ConfigFile '.\testconfig.json' -Count 10000 -PauseWhenSequenceFail 10 -OutputSequenceFile testseqfile.json -PluginModuleFilePath .\plugin.test.psm1
    Loading plugin module...
    Trying to generate 10000 sequences
    WARNING: Generated sequence was not unique, discarding sequence:
    WARNING: Generated sequence was not unique, discarding sequence:
    WARNING: Generated sequence was not unique, discarding sequence:

    ConfigFile        Sequences
    ----------        ---------
    .\testconfig.json {     ,      ,       ,      …}
#>
#Requires -Version 6.0
param(
    #Config file where all the layer data is stored.
    [Parameter(Mandatory=$true)]
    [ValidateScript({((Test-Path $_) -and (Test-Json (Get-Content $_ -Raw)))}, ErrorMessage="Config file does not exist or it is invalid")]
    [string]$ConfigFile,
    #How many nfts to generate from the datasets specified in the config file.
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [int]$Count,
    [Parameter(Mandatory=$true)]
    [ValidateScript({-not (Test-Path $_)}, ErrorMessage="Output file already exists.")]
    [string]$OutputSequenceFile,
    #When the specified number of sequences fail in a row, ask whether to keep generating (until successful or again hit fail...) or quit
    [int]$PauseWhenSequenceFail = 0,
    #To control over the sequences which are generated
    [ValidateScript({Test-Path $_}, ErrorMessage="The specified plugin module does not exist.")]
    [string]$PluginModuleFilePath
)

Get-Module "nftgen.commons" | Remove-Module
Import-Module "./nftgen.commons.psm1" -Scope Local

[bool]$plugin_module_present = Test-Path $PluginModuleFilePath;

if($plugin_module_present)
{
    Write-Host "Loading plugin module...";
    $module_name = [System.IO.Path]::GetFileNameWithoutExtension($PluginModuleFilePath)
    Get-Module $module_name | Remove-Module
    Import-Module $PluginModuleFilePath -Scope Local
    if(!$?) {
        Write-Error "Failed to load plugin module."
        exit 1
    }
}


$ConfigFile = Resolve-Path $ConfigFile


function Get-WeightedRandomTrait
{
    param([PSCustomObject[]]$Traits)

    # Calculate total weight
    $total_weight = $Traits | ForEach-Object { $_.weight } | Measure-Object -Sum | Select-Object -ExpandProperty Sum

    # Generate a random value between 0 and totalWeight
    $random_value = Get-Random -Minimum 0 -Maximum $total_weight

    # Find the selected trait based on weights
    $cumulative_weight = 0
    for ($i = 0; $i -lt $Traits.Length; $i++)
    {
        $cumulative_weight += $Traits[$i].weight;
        if ($random_value -le $cumulative_weight)
        {
            return $i
        }
    }
}

function Get-NewSequence
{
	param([PSCustomObject]$Config)

    (0..($Config.layers.Length - 1)) | ForEach-Object {
        $traits = $Config.layers[$_].traits

        $random_trait_index = Get-WeightedRandomTrait -Traits $traits
        $source_count = $traits[$random_trait_index].sources.Length;

        for([int] $i = 0; $i -lt $source_count; $i++)
        {
            [PSCustomObject]@{
                LayerIndex = $_;
                TraitIndex = $random_trait_index;
                TraitSourceIndex = $i;
            }
        }
    }
}
function Test-IsSequenceUnique
{
    param([PSCustomObject[][]]$Sequences, [PSCustomObject[]] $SequenceToTest)

    if($null -eq $SequenceToTest)
    {
        return $false;
    }

    [bool]$is_unique = $true;
    
    foreach($seq in $Sequences)
    {
        [int]$seq_len = $seq.Length;
        for($i = 0; $i -lt $seq_len; $i++)
        {
            [bool]$is_trait_equal = $seq[$i].LayerIndex -eq $SequenceToTest[$i].LayerIndex -and `
                                    $seq[$i].TraitIndex -eq $SequenceToTest[$i].TraitIndex -and `
                                    $seq[$i].TraitSourceIndex -eq $SequenceToTest[$i].TraitSourceIndex;

            if($is_trait_equal)
            {
                #check if its the last elm, if so then all the elms are same and the sequence is not unique
                if($i -eq ($seq_len - 1))
                {
                    $is_unique = $false;
                    break;
                }
            }
            else
            {
                break;
            }
        }
        if(-not $is_unique)
        {
            break;
        }
    }
    return $is_unique
}

$config = ConvertFrom-Json (Get-Content $ConfigFile -Raw)
#[System.Collections.Generic.Dictionary[string, PSCustomObject[]]]$layers_dict = Get-LayersDict -Config $config;
[System.Collections.Generic.List[PSCustomObject[]]]$sequences = [System.Collections.Generic.List[PSCustomObject[]]]::new();

Write-Host "Trying to generate $($Count) sequences"

[int]$total_failed_in_row = 0;

while ($sequences.Count -ne $Count)
{
    $seq = Get-NewSequence -Config $config;
    if($plugin_module_present)
    {
        $seq = Confirm-Sequence -GeneratedSequence $seq -LayersConfig $config;
    }
    if(Test-IsSequenceUnique -Sequences $sequences -SequenceToTest $seq)
    {
        $total_failed_in_row = 0;
        $sequences.Add($seq);
        #Write-Host "Found unique sequence: $seq, Total: $($sequences.Count)";
        [double]$progress_percentage = (([double]$sequences.Count/$Count)*100)
        Write-Progress -Activity "Sequence Generation in Progress" -Status "$progress_percentage% Complete, Current: $seq" -PercentComplete $progress_percentage
    }
    else
    {
        $total_failed_in_row++;
        Write-Warning "Generated sequence was not unique, discarding sequence: $seq";
    }

    if($PauseWhenSequenceFail -gt 0)
    {
        if($total_failed_in_row -ge $PauseWhenSequenceFail)
        {
            $cont = Read-Host "Failed $total_failed_in_row times in a row. Do you want to continue? Enter 'y' to continue"
            if([string]::IsNullOrEmpty($cont))
            {
                Write-Warning "User exit, generated total $($sequences.Count) sequences";
                break;
            }
            $total_failed_in_row = 0;
        }
    }
}
if($sequences.Count -gt 0)
{
    $ConfigFile = Resolve-Path $ConfigFile -Relative
    $seq_json = [PSCustomObject]@{
        ConfigFile = $ConfigFile
        Sequences =  $sequences
    }
    $seq_json | ConvertTo-Json -Compress -Depth 4 >> $OutputSequenceFile

    return $seq_json
}
