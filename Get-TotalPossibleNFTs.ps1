<#
.SYNOPSIS
    Calculate all possible NFTs can be generated for a collection from traits.
.DESCRIPTION
    Calculate all possible NFTs can be generated for a collection from traits.
.EXAMPLE
    .\Get-TotalPossibleNFTs.ps1 -TraitsDirectory test
    Calculating total possible NFTs for D:\projects\node\nft_art_gen_hlat\input\test
    Found 11 traits in D:\projects\node\nft_art_gen_hlat\input\test\background__z1
    Found 66 traits in D:\projects\node\nft_art_gen_hlat\input\test\base__z3
    Found 5 traits in D:\projects\node\nft_art_gen_hlat\input\test\ear__z2
    Found 22 traits in D:\projects\node\nft_art_gen_hlat\input\test\extra__z5
    Found 17 traits in D:\projects\node\nft_art_gen_hlat\input\test\eye__z6
    Found 12 traits in D:\projects\node\nft_art_gen_hlat\input\test\lip__z5
    Found 40 traits in D:\projects\node\nft_art_gen_hlat\input\test\skin__z4
    Total combination: 65165760
#>
param(
    #Specify the directoy where all the traits are located.
    [Parameter(Mandatory=$true)]
    [string]$TraitsDirectory
)

if(Test-Path $TraitsDirectory)
{
    $TraitsDirectory = Resolve-Path $TraitsDirectory
    $dir_files = Get-ChildItem $TraitsDirectory
    [int]$total_comb = 0;
    
    Write-Host "Calculating total possible NFTs for $TraitsDirectory"
    
    foreach($f in $dir_files)
    {
        if($f.PSIsContainer)
        {
            [int]$total_traits = 0;
            $traits = Get-ChildItem $f;
            foreach($tf in $traits)
            {
                if(-not $tf.PSIsContainer)
                {
                    $total_traits++;
                }
            }
            if($total_comb -ne 0)
            {
                if($total_traits -ne 0)
                {
                    Write-Host "Found $total_traits traits in $f"
                    $total_comb = $total_comb * $total_traits;
                }
            }
            else 
            {
                Write-Host "Found $total_traits traits in $f"
                $total_comb = $total_traits;
            }
        }
    }
    Write-Host "Total combination: $total_comb"
}
else 
{
    Write-Host "Traits directory does not exists. ($TraitsDirectory)"
}

