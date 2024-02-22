#Requires -Version 6.0
<#
.SYNOPSIS
    Calculate all nft rarity from the metadata
.DESCRIPTION
    Calculate all nft rarity from the metadata
.EXAMPLE
    To get rarity of each trait in the collection:
    .\Get-Rarity.ps1 -MetadataDirectory '.\output\sample4\erc721 metadata\'
    Processing...
    Rarity processed for total 500 nfts
    
    TraitName   Appeared RarityPercent TotalNfts
    ---------   -------- ------------- ---------
    SkinBase_14        6          1.20       500
    Mouth_38           6          1.20       500
    Eyes_0            15          3.00       500
    Extra_3           12          2.40       500
    Mouth_6           22          4.40       500
    Mouth_25           7          1.40       500
    Skin_2            11          2.20       500
    Mouth_29           7          1.40       500
    Mouth_2           18          3.60       500
    Wings_0          103         20.60       500
    SkinBase_57       14          2.80       500
    ...........
    ...........
.EXAMPLE
    To get rarity of a single nft in the collection:
    .\Get-Rarity.ps1 -MetadataDirectory '.\output\sample4\erc721 metadata\' -SingleNftID 1
    Processing...
    Rarity processed for total 500 nfts
    
    TraitName  Appeared RarityPercent TotalNfts
    ---------  -------- ------------- ---------
    Skin_63           7          1.40       500
    Eyes_1           25          5.00       500
    SkinBase_3       10          2.00       500
    Extra_15         27          5.40       500
    Wings_4          97         19.40       500
    Mouth_32          4          0.80       500
#>
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
    [int]$AskForContinuationWhenSpecifiedSequenceFail = 0,
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


function Get-WeightedRandom
{
    param(
        [string[]]$Traits,
        [double[]]$Weights
    )

    # Validate input arrays
    if ($Traits.Length -ne $Weights.Length) {
        throw "Traits and Weights arrays must have the same length."
    }

    # Calculate total weight
    $totalWeight = $Weights | Measure-Object -Sum | Select-Object -ExpandProperty Sum

    # Generate a random value between 0 and totalWeight
    $randomValue = Get-Random -Minimum 0 -Maximum $totalWeight

    # Find the selected trait based on weights
    $cumulativeWeight = 0
    for ($i = 0; $i -lt $Traits.Length; $i++) {
        $cumulativeWeight += $Weights[$i]
        if ($randomValue -le $cumulativeWeight) {
            return $Traits[$i]
        }
    }
}

function Get-NewSequence
{
	param([System.Collections.Generic.Dictionary[string, int[]]]$LayersDict)

    return $layers_dict.Keys | ForEach-Object {
        $traits_weights = $layers_dict[$_]
        $traits = 0..($traits_weights.Count-1)
        $random_trait = Get-WeightedRandom -Traits $traits -Weights $traits_weights
        #Write-Host "Random for the layer: $random_trait"
        $random_trait
    }
}
function Test-IsSequenceUnique
{
    param([int[][]]$Sequences, [int[]] $SequenceToTest)

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
            if($seq[$i] -eq $SequenceToTest[$i])
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
[System.Collections.Generic.Dictionary[string, int[]]]$layers_dict = Get-LayersDict -Config $config;
[System.Collections.Generic.List[int[]]]$sequences = [System.Collections.Generic.List[int[]]]::new();

Write-Host "Trying to generate $($Count) sequences"

[int]$total_failed_in_row = 0;

while ($sequences.Count -ne $Count)
{
    $seq = Get-NewSequence -LayersDict $layers_dict;
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

    if($AskForContinuationWhenSpecifiedSequenceFail -gt 0)
    {
        if($total_failed_in_row -ge $AskForContinuationWhenSpecifiedSequenceFail)
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
    $seq_json | ConvertTo-Json -Compress >> $OutputSequenceFile

    return $seq_json
}
