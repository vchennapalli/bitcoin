# Bitcoin

COP5615 - Project 4.1 (with Bonus)

# Group

Vineeth Chennapalli - 3124 2465
Akshay Rechintala - 4581 6988

# Background

1. In this part of the project, we implemented functionality components for the bitcoin network protocol. The distributed protocol will be undertaken for the second part of the project.

2. Various test cases were considered to test the functionality. They are discussed in detail in the next section.

# Test Cases Background

- Basic Functionality
  - Wallets
  - Transactions between two nodes.
  - Mining & Creation of Blockchains

- Bonus Functionality
  - Inclusion of Transaction Fee for Miners
  - Merkle Root Calculation
  - UTXO Implementation
  - Block Verification & Validation
  - Transaction Validation & Verification
  - Mempool Implementation
  - Handling forking in small networks (incorporated in functional test)
  - Base58 and Base58Check Encoding Implementation
  


# Test Case Specifications & Details

1. Unit Tests - Wallets
  
  - Base58: verifies the functionality of Base58 encoding
    - Command: mix test test/tests.exs --only base58
  
  - Base58Check: verifies the functionality of Base58Check encoding
    - Command: mix test test/tests.exs --only base58check

  - Public Key Generation: verifies the functionality of generation of public key
    - Command: mix test test/tests.exs --only public_key_gen

  - Public Address Generation: verifies the functionality of generation of public address
    - Command: mix test test/tests.exs --only public_addr_gen

  - Wallet Creation: makes sure none of the parameters in wallet are nil
    - Command: mix test test/tests.exs --only wallet_creation

  - Message Signature & Verification: tests the functionality of sign and verify functions
    - Command: mix test test/tests.exs --only sign_verify

2. Unit Tests - Transaction

  - Transaction Input Fields: verifies the input field in transaction data structure 
    - At least one input should exist and input_counter should be equal to length of inputs
    - Command: mix test test/tests.exs --only validate_input

  - Transaction Output Fields: verifies the output field in transaction data structure
    - At least one input should exist and input_counter should be equal to length of inputs
    - Command: mix test test/tests.exs --only validate_output

  - Coinbase Transaction Generation: generates a coinbase transaction
    - Command: mix test test/tests.exs --only generate_coinbase

  - Coinbase Transaction Validation: validates a coinbase transaction by checking all the fields and seeing if it has right values
    - Command: mix test test/tests.exs --only validate_coinbase

  - Transaction Validation: validates the structure of the transaction
    - Command: mix test test/tests.exs --only validate_transaction

  - Transaction Verification: verifies a transaction by making use of script public key and script signature.
    - Locking script put in the sender should be unlocked by the reciever for the receiver to use it.
    - checks if inputs sum to a value >= outputs
    - Command: mix test test/tests.exs --only verify_transaction
  

3. Unit Tests - Mining

  - Genesis Block Creation: verifies the fields of genesis block.
    - Command: mix test test/tests.exs --only create_genesis_block

  - Merkle Root Generation: 
    - Generates the merkle root for a set of transactions
    - Command: mix test test/tests.exs --only generate_merkle_root

  - Merkle Root Verification:
    - Verifies if all the transactions were included in the calculation of merkle root
    - Command: mix test test/tests.exs --only verify_merkle_root

  - Mining Proof of Work
    - Finds the nonce for a block of transactions
    - Command: mix test test/tests.exs --only generate_pow

  - Proof of Work Verification
    - Verifies whether the generated proof of work is valid or not
    - Command: mix test test/tests.exs --only validate_pow

  - Non-Empty Block Generation 
    - puts together atmost 4 transactions from the mempool and generates a block
    - Command: mix test test/tests.exs --only generate_block

4. Functional Testing of Wallet, Transactions, Block Creation & Block Mining
  i. Two users are created. The first user mines the genesis block and gets 5000000000 satoshis. 
  ii. He leaves 2% of the UTXO (5000000) for the miner and sends half of remaining amount to the second person. He sends the other half to himself. All this happens in the same transaction. 
  iii. Following that, the users make a few transactions between each other within random intervals of duration, while leaving transaction fee for the miner along the way.
  iv. Once 4 or more transactions have been received within the network, new block is mined by one of the competing blocks. 
  v. That block is sent to the neighbor, who verifies and validates it before accepting it to his blockchain.
  iv. By the end of it, the blockchain will have two blocks, and a few unconfirmed transactions pending in the mempool.
    - Command: mix test test/tests.exs --only execute_bitcoin
