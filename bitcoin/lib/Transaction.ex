defmodule Transaction do
  alias KeyGenerator, as: KG
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
    },

    :input => %{
      :tx_hash => nil,
      :tx_output_n => nil,
      :script_sig => nil
    },

    :output => %{
      :value => nil,
      :tx_output_n => nil,
      :script_pub_key => nil
    },

    :coinbase_transaction => %{
      :version => 1,
      :input_counter => 1,
      :inputs => [%{
        :tx_hash => 0x00,
        :tx_output_n => 0xFFFFFFFF,
        :coinbase => nil
      }],
      :output_counter => 1,
      :outputs => [%{
        :value => 500000000,
        :tx_output_n => 0,
        :script_pub_key => nil
      }]
    },

    :UTXO => %{
      :tx_hash => nil,
      :tx_output_n => nil,
      :script_pub_key => nil,
      :value => nil,
      :confirmations => nil
    }
  }


  @doc """
  creates a transaction
  TODO: - what if input amount < 3
  """
  def initiate_transaction(state) do
    receiver_address = select_receiver(state)
    {UXTOs, state} = select_UTXOs(state)
    transaction = Map.get(@templates, :transaction)

    {inputs, value} = construct_transaction_inputs(state, UTXOs, [], 0)

    my_address = get_in(state, [:wallet, :public_address])

    if value > 3 do
      transaction_fee = max(:math.floor(0.01 * value) |> round(), 1)
      change = value - :math.floor(transaction_fee / 2) |> round()
      non_change = value - change - transaction_fee
      value_split = [non_change, change]
      receiver_addresses = [receiver_address, my_address]
      outputs = construct_transaction_outputs(value_split, receiver_addresses, [], 0)

      transaction = Map.put(transaction, :input_counter, length(inputs))
      transaction = Map.put(transaction, :output_counter, length(outputs))
      transaction = Map.put(transaction, :inputs, inputs)
      transaction = Map.put(transaction, :outputs, outputs)
      {transaction, state}
    else
      {nil, state}
    end
  end


  @doc """
  uses UTXOs to construct input list for a transaction
  """
  def construct_transaction_inputs(state, UTXOs, inputs, value) do
    len = length(UTXOs)
    if UTXOs == nil or len == 0 do
      {inputs, value}
    else
      [UTXO | remaining_UTXOs] = UTXOs
      input = Map.get(@templates, :input)

      tx_hash = Map.get(UTXO, :tx_hash)
      input = Map.put(input, :tx_hash, tx_hash)

      tx_output_n = Map.get(UTXO, :tx_output_n)
      input = Map.put(input, :tx_output_n, tx_output_n)

      message = "#{tx_hash}:#{tx_output_n}"
      public_key = get_in(state, [:wallet, :public_key])
      private_key = get_in(state, [:wallet, :private_key])
      signature = :crypto.sign(:ecdsa, :sha256, message, [private_key, :secp256k1])
      script_sig = public_key <>signature
      input = Map.put(input, :script_sig, script_sig)

      UTXO_value = Map.get(UTXO, :value)
      value = value + UTXO_value

      inputs = inputs ++ [input]
      construct_transaction_inputs(state, remaining_UTXOs, inputs, value)
    end

  end

  @doc """
  uses the value_split and the receiver addresses to construct
  the output list of a transaction
  """
  def construct_transaction_outputs(value_split, receiver_addresses, outputs, idx) do
    if length(value_split) == 0 do
      outputs
    else
      [value | remaining_value_split] = value_split
      [receiver_address | remaining_receiver_addresses] = receiver_addresses
      output = Map.get(@templates, :output)
      output = Map.put(output, :value, value)
      output = Map.put(output, :tx_output_n, idx)
      output = Map.put(output, :script_pub_key, receiver_address)
      outputs = outputs ++ [output]
      construct_transaction_outputs(remaining_value_split, remaining_receiver_addresses, outputs, idx+1)
    end
  end

  @doc """
  selects a receiver from a list of public addresses
  """
  def select_receiver(state) do
    public_addresses = Map.get(state, :public_addresses)
    Enum.random(public_addresses)
  end

  @doc """
  selects an unused UTXO
  TODO: - more than one UTXO if possible
        - selecting based on number of confirmations
  """
  def select_UTXOs(state) do
    my_UTXOs = get_in(state, [:wallet, :my_UTXOs])
    len = length(my_UTXOs)
    if len > 0 do
      input = Enum.random(my_UTXOs)
      remaining_UTXOs = List.delete(my_UTXOs, input)
      state = put_in(state, [:wallet, :my_UTXOs], remaining_UTXOs)
      {[input], state}
    else
      {nil, state}
    end
  end


  @doc """
  receives transaction sent by a user to anonymous user
  TODO: Complete it
  """
  def receive_transaction(transaction, state) do
    mempool = Map.get(state, :mempool)

    mempool =
    if validate_transaction(transaction) do
      MapSet.put(mempool, transaction)

    end

    # state = Map.put(state, :mempool, mempool)

    # if MapSet.size(mempool) >= 4 do

    # end
  end

  @doc """
  validates every transaction before adding to mempool
  - input_counter = len(inputs)
  - output_counter = len(outputs)
  - validation of structure
  """
  def validate_transaction(transaction) do
    v = Map.get(transaction, :version)
    ic = Map.get(transaction, :input_counter)
    i = Map.get(transaction, :inputs)
    oc = Map.get(transaction, :output_counter)
    o = Map.get(transaction, :outputs)
    l = Map.get(transaction, :locktime)

    if (v == nil or
      i == [] or
      i == nil or
      ic == nil or
      oc == nil or
      o == [] or
      o == nil or
      l == nil or
      map_size(transaction) != 6 or
      ic != length(i) or
      oc != length(o)) do
      false
    else
      validate_inputs(transaction) and validate_outputs(transaction)
    end
  end

  @doc """
  validate inputs in the transaction
  """
  def validate_inputs(transaction) do
    num_inputs = length(transaction[:inputs])
    input_counter = transaction[:input_counter]
    num_inputs == input_counter
  end

  @doc """
  validate outputs in the transaction
  """
  def validate_outputs(transaction) do
    num_outputs = length(transaction[:outputs])
    output_counter = transaction[:output_counter]
    num_outputs == output_counter
  end


  @doc """
  verifies every transaction by checking the two scripts
  - locking and unlocking script
  - presence of the input in the global pool
  - sum of inputs >= sum of outputs
  """
  def verify_transaction(state, transaction) do
    inputs = Map.get(transaction, :inputs)
    all_UTXOs = Map.get(state, :all_UTXOs)

    validity = verify_all_UTXOs(all_UTXOs, inputs, true)

    if validity do
      total_input_value = get_tx_input_value(all_UTXOs, inputs, 0)
      outputs = Map.get(transaction, :outputs)
      total_output_value = get_tx_output_value(outputs, 0)
      total_input_value >= total_output_value
    else
      validity
    end
  end

  @doc """
  verifies presence of input in the global UTXOs pool
  """
  def verify_all_UTXOs(all_UTXOs, inputs, validity) do
    if length(inputs) == 0 or validity == false do
      validity
    else
      [input | remaining_inputs] = inputs
      tx_hash = Map.get(input, :tx_hash)
      tx_output_n = Map.get(input, :tx_output_n)
      key = "#{tx_hash}:#{tx_output_n}"

      single_UTXO = Map.get(all_UTXOs, key)

      validity =
      if (single_UTXO !== nil) do
        verify_single_UTXO(single_UTXO, input, key)
      else
        false
      end

      verify_all_UTXOs(all_UTXOs, remaining_inputs, validity)
    end
  end

  @doc """
  verifies the combination of locking and unlocking script
  """
  def verify_single_UTXO(single_UTXO, input, message) do
    script_pub_key = Map.get(single_UTXO, :script_public_key)
    script_sig = Map.get(input, :script_sig)
    <<public_key::bytes-size(65), signature::binary>> = script_sig
    public_address = public_key |> KG.generate_public_hash() |> KG.generate_public_address()

    if public_address != script_pub_key do
      false
    else
      :crypto.verify(:ecdsa, :sha256, message, signature, [public_key, :secp256k1])
    end
  end

  @doc """
  generates coinbase transaction
  """
  def generate_coinbase_transaction(state, transactions) do
    all_UTXOs = Map.get(state, :all_UTXOs)
    public_address = get_in(state, [:wallet, :public_address])
    {remaining_UTXOs, transactions_fee} = get_all_transactions_fee(all_UTXOs, transactions, 0)
    transaction = Map.get(@templates, :coinbase_transaction)
    outputs = Map.get(transaction, :outputs)
    [output | _] = outputs
    value = Map.get(output, :value)
    value = value + transactions_fee
    [input | _] = Map.get(transaction, :inputs)
    input = Map.put(input, :coinbase, "efa87c2618300197")
    transaction = Map.put(transaction, :inputs, [input])
    output = Map.put(output, :value, value)
    transaction = Map.put(transaction, :outputs, [output])
    transaction = Map.put(transaction, :script_pub_key, public_address)
    
    state = Map.put(state, :all_UTXOs, remaining_UTXOs)
    {state, transaction}
  end


  @doc """
  verifies and validates coinbase transaction
  """
  def validate_coinbase(transaction) do
    input_counter = Map.get(transaction, :input_counter)
    output_counter = Map.get(transaction, :output_counter)
    inputs = Map.get(transaction, :inputs)
    outputs = Map.get(transaction, :outputs)
    version = Map.get(transaction, :version)
    length(inputs) == input_counter and length(outputs) == output_counter and version != nil
  end

  @doc """
  returns the transaction fees of all transactions
  """
  def get_all_transactions_fee(all_UTXOs, transactions, fees) do
    if length(transactions) == 0 do
      {all_UTXOs, fees}
    else
      [transaction | transactions] = transactions
      {remaining_UTXOs, single_tx_fee} = get_one_transaction_fee(all_UTXOs, transaction)
      get_all_transactions_fee(remaining_UTXOs, transactions, fees + single_tx_fee)
    end
  end

  @doc """
  returns fee of single transaction
  """
  def get_one_transaction_fee(all_UTXOs, transaction) do
    inputs = Map.get(transaction, :inputs)
    outputs = Map.get(transaction, :outputs)
    {remaining_UTXOs, input_value} = get_tx_input_value(all_UTXOs, inputs, 0)
    output_value = get_tx_output_value(outputs, 0)
    {remaining_UTXOs, input_value - output_value}
  end

  @doc """
  returns total input value of single transaction
  """
  def get_tx_input_value(all_UTXOs, inputs, value) do
    if length(inputs) == 0 do
      {all_UTXOs, value}
    else
      [input | inputs] = inputs
      tx_hash = Map.get(input, :tx_hash)
      tx_output_n = Map.get(input, :tx_output_n)
      key = "#{tx_hash}:#{tx_output_n}"
      {single_UTXO, remaining_UTXOs} = Map.pop(all_UTXOs, key)
      single_value = Map.get(single_UTXO, :value)
      get_tx_input_value(remaining_UTXOs, inputs, value + single_value)
    end
  end


  @doc """
  returns total value of single transaction
  """
  def get_tx_output_value(outputs, value) do
    if length(outputs) == 0 do
      value
    else
      [output | outputs] = outputs
      single_value = Map.get(output, :value)
      get_tx_output_value(outputs, value + single_value)
    end
  end
end
