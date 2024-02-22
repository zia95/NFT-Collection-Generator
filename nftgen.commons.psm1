function Get-LayersDict
{
    [CmdletBinding()]
    param([PSCustomObject]$Config)

    #$config = ConvertFrom-Json (Get-Content $ConfigFile -Raw)
    #Write-Information "Reading config file: $ConfigFile"
    [System.Collections.Generic.Dictionary[string, int[]]]$layers_dict = [System.Collections.Generic.Dictionary[string, int[]]]::new();
    Write-Information "$($Config.name) dataset found";
    foreach($layer in $Config.layers)
    {
        Write-Information "--> $($layer.name) layer found";
        $layers_dict[$layer.name] = $layer.traits | ForEach-Object { $_.weight } #$traits_weights.ToArray();
    }
    return $layers_dict;
}

Export-ModuleMember -Function Get-LayersDict