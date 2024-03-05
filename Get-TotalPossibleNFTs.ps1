<#
.SYNOPSIS
    Calculate all possible NFTs that can be generated for a collection.
.DESCRIPTION
    Calculate all possible NFTs can be generated for a collection.
.EXAMPLE
    .\Get-TotalPossibleNFTs.ps1 -ConfigFile .\demo_test.config.json
    Dataset 'demo-test-dataset' found.
    Calculating total possible NFTs for 'demo-test-dataset' dataset.
    Total 6 layers found.
    Found 12 traits in 'Background' layer.
    Found 66 traits in 'SkinBase' layer.
    Found 40 traits in 'Skin' layer.
    Found 8 traits in 'Mouth' layer.
    Found 6 traits in 'Eyes' layer.
    Found 15 traits in 'Extra' layer.
    There are total 22809600 possible nft combinations.

    DatasetName               : demo-test-dataset
    TotalLayers               : 6
    TotalTraits               : 147
    TotalPossibleCombinations : 22809600
    Layers                    : {@{LayerName=Background; TotalTraits=12}, @{LayerName=SkinBase; TotalTraits=66},
                                @{LayerName=Skin; TotalTraits=40}, @{LayerName=Mouth; TotalTraits=8}…}
#>
#Requires -Version 6.0
param(
    #Config file where all the layer data is stored.
    [Parameter(Mandatory=$true)]
    [ValidateScript({((Test-Path $_) -and (Test-Json (Get-Content $_ -Raw)))}, ErrorMessage="Config file does not exist or it is invalid")]
    [string]$ConfigFile
)

$ConfigFile = Resolve-Path $ConfigFile

$config = ConvertFrom-Json (Get-Content $ConfigFile -Raw)

$dataset_name = $config.name;
$layer_length = $config.layers.Length;
[long]$total_traits_in_dataset = 0;
[long]$total_traits_combinations = 1;
[System.Collections.Generic.List[PSCustomObject]]$layers_info = [System.Collections.Generic.List[PSCustomObject]]::new();

Write-Output "Dataset '$dataset_name' found."
Write-Output "Calculating total possible NFTs for '$dataset_name' dataset."
Write-Output "Total $layer_length layers found."

foreach($layer in $config.layers)
{
    $layer_name = $layer.name;
    $traits_length = $layer.traits.Length;
    $total_traits_in_dataset += $traits_length;
    $total_traits_combinations *= $traits_length;

    Write-Output "Found $traits_length traits in '$layer_name' layer.";
    $li = [PSCustomObject]@{
        LayerName = $layer_name;
        TotalTraits = $traits_length;
    };
    $layers_info.Add($li);
}

Write-Output "There are total $total_traits_combinations possible nft combinations.";

[PSCustomObject]@{
    DatasetName = $dataset_name;
    TotalLayers = $layer_length;
    TotalTraits = $total_traits_in_dataset
    TotalPossibleCombinations = $total_traits_combinations;
    Layers = $layers_info.ToArray();
};