defmodule BitcoinTest do

  # alias Base58, as: B58
  # alias Base58Check, as: B58C
  # alias Block, as: B
  # alias Helper, as: H
  alias KeyGenerator, as: KG
  # alias MerkleRoot, as: MR
  # alias Mining, as: M
  alias Transaction, as: T

  use ExUnit.Case
  doctest Bitcoin

  @samples %{
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
          :value => 1399500,
          :tx_output_n => 1,
          :script_pub_key => 136367127313
        }
      ],
      :locktime => 0
    }
  }

  @tag base58: true
  @tag all: true
  test "Base58 Test1" do
    string = "Hello!"
    output = B58.encode(string)
    result = "d3yC1LKr"
    assert output == result
  end

  @tag base58: true
  @tag all: true
  test "Base58 Test2" do
    string = "Hello!"
    output = B58.encode(string)
    result = "d3yC1LKs"
    refute output == result
  end

  @tag base58check: true
  @tag all: true
  test "Base58Check Test1" do
    string = "Hello!"
    output = B58C.encode(string)
    result = "154uZdaj8TBRW4Z"
    assert output == result
  end

  @tag base58check: true
  @tag all: true
  test "Base58Check Test2" do
    string = "Hello!"
    output = B58C.encode(string)
    result = "154uZdaj8TBRW4z"
    refute output == result
  end

  @tag wallet_creation: true
  @tag all: true
  test "Wallet Creation Test1" do
    {private_key, public_key, public_address} = KG.everything()
    if (private_key == nil or public_key == nil
    or public_address == nil) do
      assert false
    else
      assert true
    end
  end

  @tag public_key_gen: true
  @tag all: true
  test "Generates Public Key Test1" do
    private_key = "21656442546439649186071776337572680887250957971064736829467793527281796997358"
    public_key = :crypto.generate_key(:ecdh, :crypto.ec_curve(:secp256k1), private_key) |> elem(0)

    output = KG.generate_public_key(private_key)

    assert output == public_key
  end

  @tag public_addr_gen: true
  @tag all: true
  test "Generates public address from public key" do
    public_key = <<4, 117, 224, 76, 123>>
    result = public_key |> H.hash(:sha256) |> H.hash(:ripemd160) |> B58C.encode(<<0x00>>)
    output = public_key |> KG.generate_public_hash() |> KG.generate_public_address()

    assert output == result
  end

  @tag sign_verify: true
  @tag all: true
  test "Verify the signature and verify functions" do
    {sk, pk, _} = KG.everything()
    message = "Hello!"
    signature = :crypto.sign(:ecdsa, :sha256, message, [sk, :secp256k1])
    assert :crypto.verify(:ecdsa, :sha256, message, signature, [pk, :secp256k1])
  end

  @tag validate_input: true
  @tag all: true
  test "validate input in transaction 1" do
    transaction = @samples[:transaction]
    assert T.validate_inputs(transaction)
  end

  @tag validate_input: true
  @tag all: true
  test "validate input in transaction 2" do
    transaction = @samples[:transaction]
    transaction = Map.put(transaction, :input_counter, 3)
    refute T.validate_inputs(transaction)
  end

  @tag validate_output: true
  @tag all: true
  test "validate output in transaction 1" do
    transaction = @samples[:transaction]
    assert T.validate_outputs(transaction)
  end

  @tag validate_output: true
  @tag all: true
  test "validate output in transaction 2" do
    transaction = @samples[:transaction]
    transaction = Map.put(transaction, :outputs,
    [%{:value => 100000, :tx_output_n => 0, :script_pub_key => 36248762376}])

    refute T.validate_outputs(transaction)
  end

  @tag validate_transaction: true
  @tag all: true
  test "validate the files in a transaction data structure 1" do
    transaction = @samples[:transaction]
    assert T.validate_transaction(transaction)
  end

  @tag verify_transaction: true
  @tag all: true
  test "verify the transaction" do
    {sk, pk, pa} = KG.everything()
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

    transaction = Map.get(@samples, :transaction)
    inputs = Map.get(transaction, :inputs)
    [input | remaining_inputs] = inputs
    script_sig = Map.get(input, :script_sig)
    tx_hash = Map.get(input, :tx_hash)
    tx_output_n = Map.get(input, :tx_output_n)
    message = "#{tx_hash}:#{tx_output_n}"
    signature = :crypto.sign(:ecdsa, :sha256, message, [sk, :secp256k1])
    script_sig = pk <> signature
    input = Map.put(input, :script_sig, script_sig)
    inputs = [input]
    transaction = Map.put(transaction, :inputs, inputs)
    transaction = Map.put(transaction, :input_counter, 1)
    assert T.verify_transaction(state, transaction)
  end

  @tag generate_coinbase: true
  @tag validate_coinbase: true
  @tag all: true
  test "generates a coinbase transaction and verifies it" do
    {sk, pk, pa} = KG.everything()
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
    transaction = @samples[:transaction]
    {new_state, transaction} = T.generate_coinbase_transaction(state, [transaction])
    
    total_reward = 500000500
    [output | _] = Map.get(transaction, :outputs)
    observed_reward = Map.get(output, :value)
    assert total_reward == observed_reward and T.validate_coinbase(transaction)
  end


  @tag create_genesis: true
  @tag all: true
  test "generates a genesis block and validates it" do
    
  end




end
