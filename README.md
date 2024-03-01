# NFT Collection Generator
This program generates nft collection out of different layers composed of traits. Its fast, flexiable and easy to use.

### Instructions
1. Use `Get-NFTGeneratorConfig` script to quicky generate config file from the layers. You can manually edit the file afterwards to adjust the weights, remove some traits, use multiple sources for the traits, and/or rename the trait.
2. After the config file for generator is done, use `Get-NFTSequence` script to generate the sequences file for the nfts. You can get more control over the sequence generator by writing a plugin module. A template has been provided to quick start.
3. Finally, the use `Get-NFTMerger` script with the sequence file and the config file to generate nfts and the ERC721 metadata. To get get more control over the metadata generation process, write logic in the plugin module. Keep in mind that this process usually takes a significant time (depends on the config & the number of sequences).
### Other helpful utility tools
1. `Get-Rarity`: Get nft collection rarity.
2. `Get-RaritySingleFromCache`: For generating rarity of each nfts and also ranking them.
3. `Get-TotalPossibleNFTs`: To calculate upper bound of maximum nfts which can be generated from the given layers.