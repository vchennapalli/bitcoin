defmodule BitcoinTest do
  use ExUnit.Case
  doctest Bitcoin

  # test "greets the world" do
  #   assert Bitcoin.hello() == :world
  # end

#Validating proof of work.
  test "checking proof of word" do
    IO.puts "Test Case : Validating proof of work"
   # Sample block for testing.
    previousHash = :crypto.hash(:sha256, "previous hash code") |> Base.encode16
    merkelRootHeader = :crypto.hash(:sha256, "merkel root header") |> Base.encode16
    m = %{:blockHash => nil,
        :version => 1,
        :previousblock => previousHash, 
        :merkelroot => merkelRootHeader,
        :time => DateTime.utc_now(), 
        :bits => "00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", 
        :nonce => 0
      }
      block = Mining.mine(m)
    assert block[:blockHash] < m[:bits]
  end

  #Validating correctness of proof of work negative case
  test "Cheching correctness of pow" do
    IO.puts "Test Case :Checking Correctness of proof of work"
    block = Block.testblock()
    block = Mining.mine(block)
    #updating block hash with some random hashcode
    randomHash = :crypto.hash(:sha256,"random string") |> Base.encode16
    block = Map.put(block,:blockHash,randomHash)

    refute block[:blockHash] < block[:bits]
  end

#Creating private key, public key and checking with the correct key.
  test "creating private key" do
  IO.puts "Test Case : Validating public key generation."
    private_key = "21656442546439649186071776337572680887250957971064736829467793527281796997358"
    #valid public key for the above private key.
    public_key = "049D1220A5F1F892C6D090ED7B3B10B1A348CD2B492B646F4183E33AAE3AE73A5E28D21F0927F7122175F241E42F84851377F34594FF593C935DCE8AF4EBDB6671"
    
    pk = KeyGenerator.generate_public_key(private_key) |> Base.encode16
    assert pk == public_key
  end

  #Testing whether the computed block is valid or not. Which includes the computation of merkel root.
  test "verifying the block" do
    IO.puts "Test Case : Validating the block"
    #Creating a sample block
    block = Block.testblock()
    #Creating the proof of work for the block
    block = Mining.mine(block)
    #Checking if the block is valid
    assert Block.verifyBlock(block)
  end

  #Testing whether the computed block if tampered is invalid or not.
  test "verifying tampered block" do
    IO.puts "Test Case : Validating tampered block"
    block = Block.testblock()
    block = Mining.mine(block)
    #Tampering the block
    block = Map.put(block,:nonce,5789)
    block = Map.put(block,:time,DateTime.utc_now)

    refute Block.verifyBlock(block)
  end

  # #Testing encode58 function
  # test "Validating encode58" do
  #   IO.put "Validating encode58"
  #   s = "hello"
  #   Base58.encode58(s)
  # end
end
