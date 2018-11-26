defmodule User do
  @moduledoc """
  contains the definitions and functions for wallet, blockchain handling, mining etc
  """
  # use GenServer

  # ASSUMPTIONS
  # All nodes are full nodes -
  # - keeps the whole blockchain
  # - verifies all the rules of Bitcoin
  # - keeps track of all UTXOs in the network

  # TODO: State
  # Components of Wallet State - private_key, public_key, public_address, UTXOs
  # Components of Blockchain - Genesis Block (?)
  # Mempool
  #
  # TODO: Structures
  # - Block
  # - Transaction Data Structure
  #
  #
  # TODO: Messeger Functions (for transactions and blocks)
  # - handle_calls (synchronous)
  #   - deliver_transaction (from originator to a random connected node in the bitcoin network)
  #
  # - handle_info (asynchronous)
  #   - propagate_transaction (to 3-4 neighbors after validation of transaction. Validation prevents attacks on the network)
  #   - propagate_block
  #
  # TODO: Private Functions
  # - get_UTXOs(val) -> returns the locked UTXOs whose total value >= val
  #

  # UNKNOWNS
  # Coinbase Transactions
  # Genesis Block


  transaction = %{
    :version => false,
    :input_counter => 2,
    :inputs => ['a', 'b'],
    :output_counter => 1,
    :outputs => ['c'],
    :locktime => 0 # default
  }

  output_structure = %{
    :value => 1 - 100000000,
    # :locking_script_size => 1 - 9, # bytes
    :scriptPubKey => "script"
  }

  input_structure = %{
    :transaction_hash => "null",
    :output_index => "null", # 4 bytes
    # :unlocking_script_size => 1 - 9, # bytes
    :scriptSig => "null"
    # :sequence_number => 0xFFFFFFFF
  }

end
