<#
.SYNOPSIS
    Calculate rarity of all nft files using a cache
.DESCRIPTION
    Calculate rarity of all nft files using a cache
.EXAMPLE
    To get rarity of each trait in the collection:
    $r = .\Get-Rarity.ps1 -MetadataDirectory '.\sample7\erc721 metadata\'
    mkdir res
    .\Get-RaritySingleFromCache.ps1 -EntireCollectionRarity $r -MetadataDirectory '.\sample7\erc721 metadata\' -OutputDirectory ".\res"
    Processing...
    ...........
    ...........
#>
#Requires -Version 6.0
param(
    #Specify the directoy where all the metadata is stored.
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_}, ErrorMessage="Metadata directory does not exists")]
    [string]$MetadataDirectory,
    #mem cache of the entire collection
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [PSCustomObject[]]$EntireCollectionRarity,
    #Directory where all the nft rarity will be stored
    [Parameter(Mandatory=$true)]
    [ValidateScript({(Test-Path $_) -and ((Get-ChildItem $_).Length -eq 0)}, ErrorMessage="Need an empty directory to store the output")]
    [string]$OutputDirectory,
    #Specify ids of nft to limit generation of rarity
    #[ValidateNotNullOrEmpty()]
    [int[]]$FilterNftsIds = $null
)

$MetadataDirectory = Resolve-Path $MetadataDirectory
$OutputDirectory = Resolve-Path $OutputDirectory
$dir_files = Get-ChildItem $MetadataDirectory
[System.Collections.Generic.List[PSCustomObject]]$ranking_result = [System.Collections.Generic.List[PSCustomObject]]::new();

Write-Host "Processing..."
[double]$total = $dir_files.Length;
[double]$total_processed = 0;
foreach($f in $dir_files)
{
    $total_processed++;
    [int]$progress_percentage = (($total_processed/$total)*100)
    if($f.PSIsContainer) {continue;}

    [int]$metadata_id = [int]::Parse([System.IO.Path]::GetFileNameWithoutExtension($f));

    if($null -ne $FilterNftsIds -and $FilterNftsIds.Length -gt 0)
    {
        [bool]$found = $false;
        foreach($nftfilter in $FilterNftsIds)
        {
            if($metadata_id -eq $nftfilter)
            {
                $found = $true;
                break;
            }
        }
        if(-not $found) { continue; }
    }

    $data = Get-Content $f | ConvertFrom-Json
    
    [bool]$found_attr_field = $false;
    foreach($prop in ($data | Get-Member))
    {
        if($prop.Name -ieq "attributes")
        {
            $found_attr_field = $true;
            break;
        }
    }
    if(-not $found_attr_field) { Write-Error "Attribute property missing in $f"; continue; }

    [System.Collections.Generic.List[PSCustomObject]]$results = [System.Collections.Generic.List[PSCustomObject]]::new();
    [double]$total_rarity = 0;
    [int]$total_rarity_fields=0;
    foreach($trait_rarity in $EntireCollectionRarity)
    {
        [bool]$does_nft_contains_trait = $false;
        foreach($trait in $data.attributes)
        {
            $trait_id = "$($trait.trait_type)_$($trait.value)"
            if($trait_rarity.TraitName -eq $trait_id)
            {
                $does_nft_contains_trait = $true;
                break;
            }
        }


        if(-not $does_nft_contains_trait) { continue; }

        #$rarity = ($traits_count_table[$tkey] / $total_nfts) * 100;
        #Write-Host "$tkey appeared $($traits_count_table[$tkey]) times and its $rarity%"
        $result = [PSCustomObject]@{
            NftId = $metadata_id
            TraitName = $trait_rarity.TraitName
            Appeared = $trait_rarity.Appeared
            RarityPercent = $trait_rarity.RarityPercent
            TotalNfts = $trait_rarity.TotalNfts
        }
        $total_rarity += $result.RarityPercent;
        $total_rarity_fields++;
        $results.Add($result);
    }
    $total_rare_ranking = [PSCustomObject]@{
        NftId = $metadata_id
        TotalRarity = ($total_rarity/$total_rarity_fields)
    }
    $ranking_result.Add($total_rare_ranking);
    
    $meta_out_file = [System.IO.Path]::Combine($OutputDirectory, "$metadata_id.csv");
    $results | ConvertTo-Csv >> $meta_out_file
    #Write-Host "Storing $meta_out_file"
    $curr_file_name = [System.IO.Path]::GetFileName($meta_out_file)
    Write-Progress -Activity "Search in Progress" -Status "$progress_percentage% Complete, Current: $curr_file_name" -PercentComplete $progress_percentage
}
$meta_ranking_out_file = [System.IO.Path]::Combine($OutputDirectory, "ranks.csv");
$ranking_result | Sort-Object -Property TotalRarity | ConvertTo-Csv >> $meta_ranking_out_file