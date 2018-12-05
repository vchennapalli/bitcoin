samples = %{
  :transaction => %{
    :version => 1,
    :input_counter => 2,
    :inputs => [
      %{
        :tx_hash => 123456,
        :tx_output_n => 0,
        :script_sig => "1472146289 23984677142"
      },
      %{
        :tx_hash => 123455,
        :tx_output_n => 1,
        :script_sig => "1472146289 23984677142"
      }
    ],
    :output_counter => 2,
    :outputs => [
      %{
        :value => 100000,
        :tx_output_n => 0,
        :script_pub_key => 36248762376
      },
      %{
        :value => 100000,
        :tx_output_n => 1,
        :script_pub_key => 136367127313
      }
    ],
    :locktime => 0
  }
}


{sk, pk, pa} = KeyGenerator.everything()
    state = %{
      :wallet => %{
        :private_key => sk,
        :public_key => pk,
        :public_address => pa,
        :my_UTXOs => [
          %{
            :tx_hash => 123456,
            :tx_output_n => 0,
            :script_public_key => pa,
            :value => 1000000,
            :confirmations => 3
          },
          %{
            :tx_hash => 123455,
            :tx_output_n => 1,
            :script_public_key => pa,
            :value => 500000,
            :confirmations => 4
          }
        ]
      },
      :blockchain => [],
      :mempool => :queue.new,
      :id => 1,
      :num_users => 5,
      :public_addresses => [],
      :all_UTXOs => %{
        "123456:0" => %{
          :tx_hash => 123456,
          :tx_output_n => 0,
          :script_public_key => pa,
          :value => 1000000,
          :confirmations => 3
        },
        "123455:1" => %{
          :tx_hash => 123455,
          :tx_output_n => 1,
          :script_public_key => pa,
          :value => 500000,
          :confirmations => 4
        }
      }
    }

    transaction = Map.get(samples, :transaction)
    inputs = Map.get(transaction, :inputs)
    [input | _] = inputs
    # script_sig = Map.get(input, :script_sig)
    tx_hash = Map.get(input, :tx_hash)
    tx_output_n = Map.get(input, :tx_output_n)
    message = "#{tx_hash}:#{tx_output_n}"
    signature = :crypto.sign(:ecdsa, :sha256, message, [sk, :secp256k1])

    script_sig = pk <> signature

    IO.inspect state

    input = Map.put(input, :script_sig, script_sig)
    inputs = [input]
    transaction = Map.put(transaction, :inputs, inputs)
    transaction = Map.put(transaction, :input_counter, 1)
    IO.puts Transaction.verify_transaction(state, transaction)
