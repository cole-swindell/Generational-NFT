📖 README – Generational NFT Smart Contract

Overview

This smart contract implements a Generational NFT system on the Stacks blockchain, where NFTs can breed to create new NFTs with inherited properties such as generation, color, size, and rarity. Each NFT keeps track of its parents, birth block, and breeding count, allowing the creation of a family tree.

✨ Features

Genesis Minting: Create generation 0 NFTs with custom metadata.

Breeding Mechanism: Two NFTs can reproduce to generate a child NFT.

Inherits generation, average size, and color (with mixing rules).

Rarity determined by parents.

Breeding requires a fee in STX.

Metadata Tracking: Each NFT stores name, generation, parents, birth block, color, size, and rarity.

Breeding Limits: Contract tracks how many times each NFT has bred.

Ownership Functions: Transfer, get owner, and check metadata.

Family Tree Lookup: Query parental lineage of any NFT.

Admin Controls: Contract owner can update breeding cost.

🛠 Functions
Public Functions

mint-genesis(recipient, name, color, size) → Mints a genesis NFT (generation 0).

breed(parent1-id, parent2-id, child-name) → Creates a child NFT with inherited traits.

transfer(token-id, sender, recipient) → Transfers ownership of an NFT.

set-breeding-cost(new-cost) → Updates the breeding fee (admin only).

Read-Only Functions

get-metadata(token-id) → Returns full NFT metadata.

get-owner(token-id) → Returns current owner of an NFT.

get-breeding-count(token-id) → Returns how many times an NFT has bred.

get-family-tree(token-id) → Returns token’s generation and parents.

get-last-token-id() → Returns the last minted token ID.

get-breeding-cost() → Returns current breeding cost.

get-token-uri(token-id) → Placeholder for token URI.

🚀 Usage Flow

Mint Genesis NFT → Start by creating base NFTs with custom traits.

Breed NFTs → Combine two NFTs to produce a child with inherited properties.

Track Family Tree → Query metadata and lineage across generations.

Trade/Transfer NFTs → Owners can transfer NFTs like any standard asset.

🔒 Error Codes

u100: Unauthorized – only contract owner allowed.

u101: Token not found.

u102: Not authorized – caller must be owner.

u103: Token already exists.

u104: Invalid generation.

u500: Internal error – unexpected failure.

📌 Notes

Breeding costs default to 1 STX (in microSTX).

Only the contract owner can adjust breeding fees.

Child traits are deterministically derived from parents.