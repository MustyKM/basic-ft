Basic FT
The Basic FT contract is a SIP-010 compliant fungible token implementation written in Clarity for the Stacks blockchain.
It provides a simple and secure token model for DeFi, governance, or utility use cases.

Features
Fully SIP-010 compliant
Minting, transferring, and burning functions
Balance and total supply tracking
Token metadata (name, symbol, decimals)
Event logs for all transfers and burns

Technical Overview
Language: Clarity
Standard: SIP-010 (Stacks Fungible Token Standard)
Core Functions:
transfer – move tokens between users
mint – create new tokens (admin only)
burn – destroy tokens from circulation
get-balance – view user token balance
get-total-supply – total tokens in existence
Metadata:
get-name – returns token name
get-symbol – returns token symbol
get-decimals – returns decimal precision
