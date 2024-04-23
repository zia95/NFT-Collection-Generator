<#
.SYNOPSIS
    Filter NFTs by provided metadata
.DESCRIPTION
    Filter NFTs by provided metadata
.EXAMPLE
    Filter the metadata by name of nft
    .\Where-NFT.ps1 .\output\sl_sample_12\ -Filter {$_.name -like "NFT*"}

    name      description          image                   attributes
    ----      -----------          -----                   ----------
    NFT #0    This NFT Id is #0    ipfs://__CID__/0.png    {@{trait_type=Background; value=Cliffs}, @{trait_type=SkinBase;…
    NFT #1    This NFT Id is #1    ipfs://__CID__/1.png    {@{trait_type=Background; value=Black Broken Glass}, @{trait_ty…
    NFT #10   This NFT Id is #10   ipfs://__CID__/10.png   {@{trait_type=Background; value=Structure}, @{trait_type=Extra;…
    .......
    .......
.EXAMPLE
    Filter the metadata by the traits of nfts
    .\Where-NFT.ps1 .\output\sl_sample_12\ -Filter {$_.attributes | Where-Object {$_.trait_type -eq "Background" -and $_.value -like "Top*" } }

    name      description          image                   attributes
    ----      -----------          -----                   ----------
    NFT #1002 This NFT Id is #1002 ipfs://__CID__/1002.png {@{trait_type=Background; value=Top Blocks}, @{trait_type=SkinB…
    NFT #1003 This NFT Id is #1003 ipfs://__CID__/1003.png {@{trait_type=Background; value=Top Blocks}, @{trait_type=SkinB…
    NFT #1026 This NFT Id is #1026 ipfs://__CID__/1026.png {@{trait_type=Background; value=Top Blocks}, @{trait_type=SkinB…
    .......
    .......
#>
#Requires -Version 6.0
[CmdletBinding()]
param(
    #Directory where all the erc721 nft metadata is stored.
    [Parameter(Mandatory=$true)]
    [ValidateScript({(Test-Path $_) -and ((Get-ChildItem $_).Length -ne 0)}, ErrorMessage="The directory does not exists or is empty.")]
    [string]$ERC721MetadataDirectory,
    #Script block where all the filter criteria is present.
    [Parameter(Mandatory=$true)]
    [System.Management.Automation.ScriptBlock]$Filter
)

$metadata_files = Get-ChildItem $ERC721MetadataDirectory -Filter "*.json";

$metadatas = $metadata_files | ForEach-Object { Get-Content $_ -Raw | ConvertFrom-Json}

$metadatas | Where-Object $Filter