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
function move_sequence {
    param (
        [PSCustomObject[]]$GeneratedSequence,
        [int]$SourceIndex,
        [int]$DestinationIndex
    )
    for($i = 0; $i -lt $GeneratedSequence.Length; $i++)
    {
        if($i -eq $SourceIndex)
        {
            continue;
        }
        
        if($i -eq $DestinationIndex)
        {
            $GeneratedSequence[$SourceIndex];
            $GeneratedSequence[$DestinationIndex];
            continue;
        }
        
        $GeneratedSequence[$i];
    }
}

$back_fan_or_wings_traits_name = @("Back Fan", "Bat Wings 1", "Bat Wings 2", "Bat Wings with Cracked Skull", "Bat Wings With Hair", "Black Bat Wings With Hair", `
"Black Bat Wings", "Black Wings with Cracked Skull", "Eagle Wings with Cracked Skull", "Eagle Wings With Hair", "Eagle Wings", "Red Wings 1", "Red Wings with Cracked Skull", "Red Wings With Hair");
$cracked_skull_or_earrings_or_long_hair_or_plants_head_traits_name = @("Cracked Skull 2", "Cracked Skull 3", "Earring 1", "Earring 2", "Long Hair", "Plants Head");
function Confirm-Sequence
{
    param(
        [PSCustomObject[]]$GeneratedSequence,
        [PSCustomObject]$LayersConfig
        )

    #confirm if the sequence is correct.
    #transform it if necessary
    #return $null to discard a sequence
    $GenSeqLen = $GeneratedSequence.Length;
    
    $big_tongue_index = -1;
    $back_fan_or_wings_index = -1;
    $cracked_skull_or_earrings_or_long_hair_or_plants_head_index = -1;
    $snake_crown_index = -1;
    for($i = 0; $i -lt $GeneratedSequence.Length; $i++)
    {
        if($GeneratedSequence[$i].LayerIndex -eq 3 -and $GeneratedSequence[$i].TraitIndex -eq 3)
        {
            $big_tongue_index = $i;
            continue;
        }
        if($GeneratedSequence[$i].LayerIndex -eq 5)
        {
            $layer_idx = $GeneratedSequence[$i].LayerIndex;
            $trait_idx = $GeneratedSequence[$i].TraitIndex;
            $trait_name = $LayersConfig.layers[$layer_idx].traits[$trait_idx].name;
            
            if($trait_name  -in $back_fan_or_wings_traits_name)
            {
                if($GeneratedSequence[$i].TraitSourceIndex -eq 0)
                {
                    $back_fan_or_wings_index = $i;
                    continue;
                }
            }
            if($trait_name -in $cracked_skull_or_earrings_or_long_hair_or_plants_head_traits_name)
            {
                if($GeneratedSequence[$i].TraitSourceIndex -eq 0)
                {
                    $cracked_skull_or_earrings_or_long_hair_or_plants_head_index = $i;
                    continue;
                }
            }
            if($trait_name -eq "Snake Crown")
            {
                if($GeneratedSequence[$i].TraitSourceIndex -eq 0)
                {
                    $snake_crown_index = $i;
                    continue;
                }
            }
        }
    }
    
    if($snake_crown_index -ne -1)
    {
        $GeneratedSequence = $GeneratedSequence | Where-Object { $LayersConfig.layers[$_.LayerIndex].name -ne "Eyes" }
    }
    if($back_fan_or_wings_index -ne -1)
    {
        $to_swap_idx = 1;
        $GeneratedSequence = move_sequence -GeneratedSequence $GeneratedSequence -SourceIndex $back_fan_or_wings_index -DestinationIndex $to_swap_idx
    }
    if($big_tongue_index -ne -1)
    {
        if($back_fan_or_wings_index -ne -1)
        {
            return $null;
        }
        $to_swap_idx = $GenSeqLen - 1;
        swap_sequence -GeneratedSequence $GeneratedSequence -IndexOne $big_tongue_index -IndexTwo $to_swap_idx
    }
    if($cracked_skull_or_earrings_or_long_hair_or_plants_head_index -ne -1)
    {
        $to_swap_idx = $cracked_skull_or_earrings_or_long_hair_or_plants_head_index - 2;
        swap_sequence -GeneratedSequence $GeneratedSequence -IndexOne $cracked_skull_or_earrings_or_long_hair_or_plants_head_index -IndexTwo $to_swap_idx
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