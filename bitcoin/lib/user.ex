defmodule User do
  alias Block, as: B
  alias Transaction, as: T
  alias Helper, as: H
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
      :receive_transaction -> T.receive_transaction(message, state)
      :receive_block -> receive_block(message, state)
      :perform_transaction -> perform_transaction(message, state)
    end
  end

  def handle_info({:genesis}, state) do

  end


  defp create_block(state) do
    nil
  end

  defp receive_block(_message, _state) do
    nil
  end

  defp perform_transaction(message, state) do
    public_addresses = Map.get(state, :public_addresses)

    destination = Enum.random(public_addresses)

    UTXO = get_input(state)


    # if UTXO !== nil



  end


  defp select_neighbor(state) do
    num_users = Map.get(state, :num_users)

  end


  defp get_input(state) do
    UTXOs = get_in(state, [:wallet, :UTXOs])
    public_address = get_in(state, [:wallet, :public_address])
    hashed_public_address = public_address |> Helper.hash(:sha256)
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

end
