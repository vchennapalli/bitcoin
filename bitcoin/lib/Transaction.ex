defmodule Transaction do
  @moduledoc """
  contains all the functionality relevant to transactions
  """
  @templates %{
    :transaction => %{
      :version => 1,
      :input_counter => 0,
      :inputs => [],
      :output_counter => 0,
      :outputs => [],
      :locktime => 0 # default
    },

    :input => %{
      :tx_hash => nil,
      :output_index => nil, # 4 bytes
      # :unlocking_script_size => 1 - 9, # bytes
      :scriptSig => nil
      # :sequence_number => 0xFFFFFFFF
    },

    :output => %{
      :value => nil,
      # :locking_script_size => 1 - 9, # bytes
      :scriptPubKey => nil
    },

    :coinbase_trasaction => %{
      :hash => nil,
      :version => 1,
      :input_counter => 1,
      :inputs => [%{
        :tx_hash => 0,
        :output_index => 0xFFFFFFFF,
        :coinbase_data => "", # 2-100 bytes
        :sequence_number => 0xFFFFFFFF
      }],
      :output_counter => 1,
      :outputs => [%{
        :value => 500000000,
        :scriptPubKey => ""
      }]
    },

    :UTXO => %{
      :tx_hash => "",
      :tx_output_n => "",
      :value => "",
      :confirmations => ""
    }
  }

  @doc """
  receives transaction sent by a user to anonymous user
  """
  def receive_transaction(transaction, state) do
    mempool = Map.get(state, :mempool)

    mempool =
    if validate_transaction(transaction) do
      MapSet.put(mempool, transaction)

    end

    state = Map.put(state, :mempool, mempool)

    if MapSet.size(mempool) >= 4 do

    end
  end

  @doc """
  validates every transaction before adding to mempool
  """
  def validate_transaction(_transaction) do

  end

  @doc """
  verifies every transaction by checking the two scripts
  """
  def verify_transaction(_transaction) do

  end

  @doc """
  generates coinbase transaction
  """
  def generate_coinbase_transaction(transactions) do
    _transaction_fees = get_transaction_fees(transactions)
    #TODO: add functionality
    nil
  end

  @doc """
    returns the transaction fees left in the transactions
  """
  def get_transaction_fees(_transactions) do
    nil
  end

end
