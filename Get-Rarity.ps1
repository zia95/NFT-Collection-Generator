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
#Requires -Version 6.0
param(
    #Specify the directoy where all the metadata is stored.
    [Parameter(Mandatory=$true)]
    [string]$MetadataDirectory,
    #Measure single NFT rarity
    [int]$SingleNftID = -1
)

if(-not (Test-Path $MetadataDirectory))
{
    Write-Error "Metadata directory does not exists. ($MetadataDirectory)"
    exit 1
}

$MetadataDirectory = Resolve-Path $MetadataDirectory
$dir_files = Get-ChildItem $MetadataDirectory
$total_nfts = 0;
[Hashtable]$traits_count_table = @{};
[Hashtable]$single_traits_count_table = $null;

Write-Host "Processing..."

foreach($f in $dir_files)
{
    if(-not $f.PSIsContainer)
    {
        $data = Get-Content $f | ConvertFrom-Json
        
        [bool]$single_nft_found = $false;
        if($SingleNftID -ne -1)
        {
            [int]$metadata_id = [int]::Parse([System.IO.Path]::GetFileNameWithoutExtension($f));
            if($metadata_id -eq $SingleNftID)
            {
                $single_nft_found = $true
            }
        }
        
        [bool]$attr_exist = $false
        
        foreach($prop in ($data | Get-Member))
        {
            if($prop.Name -ieq "attributes")
            {
                $attr_exist = $true
                break;
            }
        }
        
        if($attr_exist -eq $false)
        {
            Write-Error "Attribute property missing in $f";
            continue;
        }
        
        foreach($trait in $data.attributes)
        {
            $trait_id = "$($trait.trait_type)_$($trait.value)"
            $traits_count_table[$trait_id] += 1;
            if($single_nft_found)
            {
                if($null -eq $single_traits_count_table)
                {
                    $single_traits_count_table = @{};
                }
                if($single_nft_found)
                {
                    $single_traits_count_table[$trait_id] += 1;
                }
            }
        }
    }
    $total_nfts++;
}

[System.Collections.Generic.List[PSCustomObject]]$results = [System.Collections.Generic.List[PSCustomObject]]::new();

Write-Host "Rarity processed for total $total_nfts nfts"

foreach($tkey in $traits_count_table.Keys)
{
    if($SingleNftID -ne -1)
    {
        if($null -eq $single_traits_count_table)
        {
            Write-Error "NFT with ID $SingleNftID does not exist."
            exit 2
        }
        if(-not $single_traits_count_table.ContainsKey($tkey))
        {
            continue;
        }
    }
    
    $rarity = ($traits_count_table[$tkey] / $total_nfts) * 100;
    #Write-Host "$tkey appeared $($traits_count_table[$tkey]) times and its $rarity%"
    $result = [PSCustomObject]@{
        TraitName = $tkey
        Appeared = $traits_count_table[$tkey]
        RarityPercent = $rarity
        TotalNfts = $total_nfts
    }
    $result
    $results.Add($result);
}
#return $results
