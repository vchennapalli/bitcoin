defmodule User do
  @moduledoc """
  contains the definitions and functions for wallet, blockchain handling, mining etc
  """
  use GenServer

  # ASSUMPTIONS
  # All nodes are full nodes -
  # - keeps the whole blockchain
  # - verifies all the rules of Bitcoin
  # - keeps track of all UTXOs in the network
  #
  # TODO: Messeger Functions (for transactions and blocks)
  # - handle_calls (synchronous)
  #   - deliver_transaction (from originator to a random connected node in the bitcoin network)
  #
  # - handle_info (asynchronous)
  #   - propagate_transaction (to 3-4 neighbors after validation of transaction. Validation prevents attacks on the network)
  #   - propagate_block
  #
  # UNKNOWNS
  # Coinbase Transactions
  # Genesis Block

  @doc """
  first step
  """
  def start_link(status) do
    GenServer.start_link(__MODULE__, status)
  end

  @doc """
  initialize the process
  """
  def init(args) do
    IO.inspect args
    {:ok, args}
  end


  def handle_cast({tag, message}, state) do
    new_state =
    case tag do
      :receive_transaction -> receive_transaction(message, state)
      :receive_block -> receive_block(message, state)
      :perform_transaction -> perform_transaction(message, state)
    end
  end

  defp receive_transaction(transaction, state) do

    mempool = Map.get(state, :mempool)

    mempool =
    if validate_transaction(transaction) do
      MapSet.put(mempool, transaction)

    end

    state = Map.put(state, :mempool, mempool)

    if MapSet.size(mempool) >= 4 do

    end
  end


  defp create_block(mempool) do

  end

  defp validate_transaction(transaction) do

  end

  defp receive_block(_message, _state) do
    nil
  end

  defp perform_transaction(message, state) do
    public_addresses = Map.get(state, :public_addresses)

    destination = Enum.random(public_addresses)

    UTXO = get_input(state)



  end


  defp select_neighbor(state) do
    num_users = Map.get(state, :num_users)

  end


  defp get_input(state) do
    UTXOs = get_in(state, [:wallet, :UTXOs])
    public_address = get_in(state, [:wallet, :public_address])
    hashed_public_address = :crypto.hash(:sha256, public_address)
    UTXO = lookup_utxos(UTXOs, hashed_public_address)
  end

  defp lookup_utxos([UTXO | UTXOs], hashed_public_address) do
    script_val = Map.get(UTXO, :scriptPubKey)
    if script_val == hashed_public_address do
      UTXO
    else
      lookup_utxos(UTXOs, hashed_public_address)
    end
  end

  defp lookup_utxos([], _) do
    nil
  end



  transaction = %{
    :hash => "",
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
    :tx_hash => nil,
    :output_index => nil, # 4 bytes
    # :unlocking_script_size => 1 - 9, # bytes
    :scriptSig => nil
    # :sequence_number => 0xFFFFFFFF
  }


  coinbase_transaction = %{
    :hash => "",
    :version => false,
    :input_counter => 1,
    :inputs => [%{
      :coinbase => "",
      :sequence_number => ""
    }],
    :output_counter => 1,
    :outputs => [%{
      :value => 500000000,
      :scriptPubKey => "script"
    }]
  }

  UTXO_format = %{
    :tx_hash => "",
    :tx_output_n => "",
    :value => "",
    :confirmations => ""
  }


end
