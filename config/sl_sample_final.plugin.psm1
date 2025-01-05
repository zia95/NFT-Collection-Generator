<#
this function performs in-place reordering of a sequence by swaping one trait to another trait location
#>
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
<#
this function reorders a sequence by moving source trait to the dest trait location and returns the reordered sequence
#>
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

$back_fan_or_wings_or_muffler_traits_name = @("Back Fan", "Bat Wings", "Bat Wings Plain", "Bat Wings with Cracked Skull", "Bat Wings With Hair", "Black Bat Wings With Hair", `
"Black Bat Wings", "Black Wings with Cracked Skull", "Eagle Wings with Cracked Skull", "Eagle Wings With Hair", "Eagle Wings", "Red Wings 1", "Red Wings with Cracked Skull", `
"Red Wings With Hair", "Muffler");

$cracked_skull_or_earrings_or_long_hair_or_plants_head_traits_name = @("Cracked Skull Extreme Dark", "Cracked Skull Extreme", "Earring", "Green Earring", "Long Hair", "Plants Head", "Flower Head");

$skip_skin_names = @("Green Skull 3", "Yellow Skull 2", "Black Skull 1", "Black Skull 3", "Black Skull 5", "Black Skull 4", "Purple Skull 7", "Purple Skull 5", `
"Orange Skull 1", "Orange Skull 1", "Green Skull 4", "Purple Skull 2", "Purple Skull 4", "Purple Skull 3", "Red Skull 3", "Brown Skull 2", "Purple Skull 2", `
"Purple Skull 1", "Orange Skull 1", "Pink Skull 1", "Pink Skull 1", "Orange Skull 1", "Blue Skull 2", "Black Skull 4", "Orange Skull 1", "Green Skull 6", `
"Green Skull 8", "Orange Skull 1", "Green Skull 8", "Green Skull 6", "Purple Skull 4", "Green Skull 6", "Purple Skull 1", "Orange Skull 1");

$skip_skinbase_names = @("Black 1", "Black 1", "Black 1", "Black 1", "Black 1", "Black 1", "Black 1", "Brown 2", "Purple 3", "Green 3", "Blue 3", "Purple 1", `
"Blue 3", "Purple 1", "Green 8", "Purple 1", "Purple 1", "Green 8", "Red 4", "Purple 1", "Blue 3", "Red 2", "Purple 1", "Purple 1", "Red 6", "Green 8", "Red 1", `
"Red 6", "Green 8", "Purple 1", "Purple 1", "Blue 3", "Purple 1", "Candy");

$tooth_mouth_traits = @("Blue Tooth 1","Blue Tooth 2","Blue Tooth 3","Blue Tooth 4","Blue Tooth 5","Blue Tooth 6","Blue Tooth 7","Blue Tooth 8","Blue Tooth 9","Brown Tooth 1", `
"Brown Tooth 2","Brown Tooth 3","Brown Tooth 4","Brown Tooth 5","Brown Tooth 6","Green Tooth 1","Green Tooth 2","Green Tooth 3","Green Tooth 4","Green Tooth 5","Pink Tooth 1", `
"Purple Tooth 1","Purple Tooth 2","Purple Tooth 3","Purple Tooth 4","Red Tooth 1","Red Tooth 2","Red Tooth 3","Red Tooth 4","Red Tooth 5","Red Tooth 6","White Tooth 1","Yellow Tooth 1", `
"Yellow Tooth 2","Yellow Tooth 3","Yellow Tooth 4","Yellow Tooth 5","Yellow Tooth 6","Yellow Tooth 7");

$tooth_skin_tratis = @("Black Tooth Skull 1","Black Tooth Skull 2","Black Tooth Skull 3","Black Tooth Skull 4","Black Tooth Skull 5","Black Tooth Skull 6","Blue Tooth Skull 2", `
"Brown Tooth Skull 1","Brown Tooth Skull 2","Brown Tooth Skull 3","Brown Tooth Skull 4","Green Tooth Skull 2","Green Tooth Skull 3","Green Tooth Skull 4","Green Tooth Skull 5", `
"Green Tooth Skull 6","Green Tooth Skull 7","Green Tooth Skull 8","Green Tooth Skull 9","Purple Tooth Skull 1","Purple Tooth Skull 2","Purple Tooth Skull 3","Purple Tooth Skull 4", `
"Purple Tooth Skull 5","Purple Tooth Skull 6","Purple Tooth Skull 8","Red Tooth Skull 1","Red Tooth Skull 2","Red Tooth Skull 3","Yellow Tooth Skull 1","Yellow Tooth Skull 5","Yellow Tooth Skull 6");

$mouth_big_tongue_trait = "Tongue Out"

$ext_layer_traits_require_no_eyes = @("Snake Crown", "Snakes", "Octopus Tentacle", "Black Glasses With Hair")
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
    
    $curr_seq_skin_base_name = $null;
    $curr_seq_skin_name = $null;
    $curr_seq_mouth_name = $null;
    $curr_seq_extra_name = $null;
    
    $curr_seq_mouth_src_0_index = -1;
    $curr_seq_extra_src_0_index = -1;
    for($i = 0; $i -lt $GeneratedSequence.Length; $i++)
    {
        $layer_idx = $GeneratedSequence[$i].LayerIndex;
        $trait_idx = $GeneratedSequence[$i].TraitIndex;
        $layer_name = $LayersConfig.layers[$layer_idx].name;
        $trait_name = $LayersConfig.layers[$layer_idx].traits[$trait_idx].name;

        if($layer_name -eq "SkinBase")#index:1 == skinbase
        {
            $curr_seq_skin_base_name = $trait_name;
        }
        if($layer_name -eq "Skin")#index:2 == skin
        {
            $curr_seq_skin_name = $trait_name;
        }
        if ($layer_name -eq "Mouth")
        {
            $curr_seq_mouth_name = $trait_name;
            if($GeneratedSequence[$i].TraitSourceIndex -eq 0)
            {
                $curr_seq_mouth_src_0_index = $i;
                continue;
            }
        }
        if($layer_name -eq "Extra")
        {
            $curr_seq_extra_name = $trait_name;
            if($GeneratedSequence[$i].TraitSourceIndex -eq 0)
            {
                $curr_seq_extra_src_0_index = $i;
                continue;
            }
        }
    }
    <#
    This is to make sure tooth traits only match with other tooth traits.
    #>
    if($curr_seq_skin_name -in $tooth_skin_tratis -and $curr_seq_mouth_name -notin $tooth_mouth_traits)
    {
        Write-Warning "skipped because tooth skin is picked but mouth trait does not belong to tooth trait set.";
        return $null;
    }
    if($curr_seq_mouth_name -in $tooth_mouth_traits -and $curr_seq_skin_name -notin $tooth_skin_tratis)
    {
        Write-Warning "skipped because tooth mouth is picked but skin trait does not belong to tooth trait set.";
        return $null;
    }
    <#
    This is to make sure proper skin match with skin base
    #>
    for($i = 0; $i -lt $skip_skin_names.Length; $i++)
    {
        if($curr_seq_skin_name -eq $skip_skin_names[$i])
        {
            if($curr_seq_skin_base_name -eq $skip_skinbase_names[$i])
            {
                Write-Warning "skipped because of skip match... curr $curr_seq_skin_name -- $curr_seq_skin_base_name"
                return $null;
            }
        }
    }
    <#
    adjust these traits layer order because they don't follow the default one.
    #>
    if($curr_seq_extra_name -in $back_fan_or_wings_or_muffler_traits_name)
    {
        $to_swap_idx = 1;
        $GeneratedSequence = move_sequence -GeneratedSequence $GeneratedSequence -SourceIndex $curr_seq_extra_src_0_index -DestinationIndex $to_swap_idx
    }
    <#
    adjust these traits layer order because they don't follow the default one.
    #>
    if($curr_seq_mouth_name -eq $mouth_big_tongue_trait)
    {
        if($curr_seq_extra_name -in $back_fan_or_wings_or_muffler_traits_name)
        {
            return $null;
        }
        $to_swap_idx = $GenSeqLen - 1;
        swap_sequence -GeneratedSequence $GeneratedSequence -IndexOne $curr_seq_mouth_src_0_index -IndexTwo $to_swap_idx
    }
    <#
    adjust these traits layer order because they don't follow the default one.
    #>
    if($curr_seq_extra_name -in $cracked_skull_or_earrings_or_long_hair_or_plants_head_traits_name)
    {
        $to_swap_idx = $curr_seq_extra_src_0_index - 2;
        swap_sequence -GeneratedSequence $GeneratedSequence -IndexOne $curr_seq_extra_src_0_index -IndexTwo $to_swap_idx
    }
    <#
    remove eyes trait when snake crow trait is present because it comes with eyes already.
    #>
    if($curr_seq_extra_name -in $ext_layer_traits_require_no_eyes)
    {
        $GeneratedSequence = $GeneratedSequence | Where-Object { $LayersConfig.layers[$_.LayerIndex].name -ne "Eyes" }
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
    $name = $GeneratedMetadata.name
    $desc = $GeneratedMetadata.description
    $image = $GeneratedMetadata.image
    $attr = $GeneratedMetadata.attributes
    foreach ($trait in $attr) {
        $trait_type = $trait.trait_type
        $trait_value = $trait.value
        if(($trait_type -eq "Extra") -and $trait_value -in $ext_layer_traits_require_no_eyes)
        {
            $GeneratedMetadata.attributes = $GeneratedMetadata.attributes + [PSCustomObject]@{ trait_type = "Eyes"; value = $trait_value }
            break;
        }
    }

    return $GeneratedMetadata;
}

Export-ModuleMember -Function Confirm-Sequence
Export-ModuleMember -Function Confirm-ERC721Metadata