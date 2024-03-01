function Confirm-Sequence
{
    param(
        [PSCustomObject[]]$GeneratedSequence,
        [PSCustomObject]$LayersConfig
        )

    #confirm if the sequence is correct.
    #transform it if necessary
    #return $null to discard a sequence

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