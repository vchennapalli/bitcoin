defmodule Block do
    alias Helper, as: H
    alias Transaction, as: T
    alias MerkleRoot, as: MR

    @moduledoc """
    contains all functionality related to block handling
    """
    @template %{
      :block => %{
        :size => nil,
        :header => %{
          :version => 1,
          :previous_block_hash => "0000000000000000000000000000000000000000000000000000000000000000",
          :merkle_root => nil,
          :timestamp => nil,
          :bits => "00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          :nonce => nil
        },
        :num_transaction => nil,
        :transactions => []
      }
    }

    @tpb 4 #transactions per block, including coinbase transaction

    @doc """
    creates a block
    """
    def create(state) do

      #NOTE: 1st transaction is reward + fees
      mempool = Map.get(state, :mempool)
      transactions = select_transactions(mempool)
      coinbase_transaction = T.generate_coinbase_transaction(transactions)
      merkle_root = [coinbase_transaction] ++ transactions |> MR.get_root()

      nil
    end

    @doc """
    selects transactions from mempool
    """
    def select_transactions(_mempool) do
      #TODO: Add Functionality
      nil
    end



    @doc """
    receives new block from a neighbor
    """
    def receive(block, _state) do
      #TODO: Add Functionality
      validate(block)

    end

    @doc """
    validates the received block
    """
    def validate(block) do
      validate_syntax(block)
      validate_transactions(block)
      validate_pow(block)
      validate_coinbase(block)
      #TODO: Add Functionality
      nil
    end

    @doc """
    checks if the block is syntatically correct
    """
    def validate_syntax(_block) do
      #TODO: Add Functionality
      nil
    end

    @doc """
    checks if every transaction mentioned in the block is considered
    while calculating the merkle root
    """
    def validate_transactions(_block) do
      #TODO: Add Functionality
      nil
    end

    @doc """
    checks if the proof of work was calculated correctly
    """
    def validate_pow(_block) do
      #TODO: Add Functionality
      nil
    end

    @doc """
    - checks if appropriate coinbase reward was included
    - checks if only one coinbase transaction is present
    - checks if the fees has been added properly
    """
    def validate_coinbase(_block) do
      #TODO: Add Functionality
      nil
    end


  #   @doc """
  #     verifies whether a valid block was created or not
  #     """
  #     def verify_block(block) do
  #       version = block[:version]
  #       previousblock = block[:previousblock]
  #       merkelroot = block[:merkelroot]
  #       time = block[:time]
  #       bits = block[:bits]
  #       nonce = block[:nonce]
  #       blockhash = block[:blockhash]

  #       check(version,previousblock,merkelroot,time,bits,nonce,blockhash)
  #   end

  #   defp check(version,previousblock,merkelroot,time,bits,nonce,blockhash) do
  #       ha = :crypto.hash(:sha256,"#{version}#{previousblock}#{merkelroot}#{time}#{nonce}")|>Base.encode16
  #       blockhash == :crypto.hash(:sha256,ha) |> Base.encode16 and blockhash <= bits
  #   end

  # # Test block which created a sample block for testing.
  #   def testblock() do
  #       h = :crypto.hash(:sha256, "previous hash code")
  #       mr = :crypto.hash(:sha256, "merkel root header")
  #       m = %{ :blockHash => nil,
  #       :version => 1,
  #       :previousblock => h ,
  #       :merkelroot => mr ,
  #       :time => DateTime.utc_now(),
  #       #:bits => 1d00ffff
  #       :bits => "00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
  #       :nonce => 0,
  #       :transactions => []
  #     }
  #     m
  #   end

  #    # def test() do
  #   #     list = [1,2,3]
  #   #     createMTree(list)
  #   # end

  #   # def test do
  #   #     h = :crypto.hash(:sha256, "previous hash code")
  #   #     mr = :crypto.hash(:sha256, "merkel root header")
  #   #     m = %{ :blockHash => nil,
  #   #     :version => 1,
  #   #     :previousblock => h ,
  #   #     :merkelroot => mr ,
  #   #     :time => DateTime.utc_now(),
  #   #     #:bits => 1d00ffff
  #   #     :bits => "003fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
  #   #     :nonce => 0,
  #   #     :transactions => []
  #   #   }
  #   #   block = Mining.mine(m)

  #   #   verifyBlock(block)

  #   # end

  end
