function swap_sequence {
    param (
        [PSCustomObject[]]$GeneratedSequence,
        [int]$IndexOne,
        [int]$IndexTwo
    )
    $t = $GeneratedSequence[$IndexOne]
    $GeneratedSequence[$IndexOne] = $GeneratedSequence[$IndexTwo];
    $GeneratedSequence[$IndexTwo] = $t;
}


function Confirm-Sequence
{
    param(
        [PSCustomObject[]]$GeneratedSequence,
        [PSCustomObject]$LayersConfig
        )

    #confirm if the sequence is correct.
    #transform it if necessary
    #return $null to discard a sequence
    
    for($i = 0; $i -lt $GeneratedSequence.Length; $i++)
    {
        if($GeneratedSequence[$i].LayerIndex -eq 3 -and $GeneratedSequence[$i].TraitIndex -eq 3)
        {
            $to_swap_idx = $GeneratedSequence.Length - 1;
            swap_sequence -GeneratedSequence $GeneratedSequence -IndexOne $i -IndexTwo $to_swap_idx
        }
    }
    
    return $GeneratedSequence;
}
function Confirm-ERC721Metadata
{
    param(
        [int]$Id,
        [PSCustomObject[]]$GeneratedSequence,
        [PSCustomObject]$GeneratedMetadata,
        [PSCustomObject]$LayersConfig
        )

    #confirm if the metadata is correct.
    #transform it if necessary.

    return $GeneratedMetadata;
}

Export-ModuleMember -Function Confirm-Sequence
Export-ModuleMember -Function Confirm-ERC721Metadata