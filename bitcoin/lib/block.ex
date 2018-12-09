defmodule Block do
    alias Helper, as: H
    alias Transaction, as: T
    alias MerkleRoot, as: MR
    alias Mining, as: M

    @moduledoc """
    contains all functionality related to block handling
    """
    @template %{
      :new_block => %{
        # :size => nil,
        :header => %{
          :version => 1,
          :previous_block_hash => "0000000000000000000000000000000000000000000000000000000000000000",
          :merkle_root => nil,
          :timestamp => nil,
          :bits => "0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          :nonce => 0
        },
        :num_transactions => nil,
        :transactions => []
      }
    }

    # @tpb 1 #transactions per block, including coinbase transaction

    @doc """
    creates a block
    """
    def create(state) do
      #NOTE: 1st transaction is reward + fees
      mempool = Map.get(state, :mempool)
      mempool_list = Map.to_list(mempool)
      {transactions, keys} = select_transactions(mempool_list, [], [])
      mempool = Map.drop(mempool, keys)
      state = Map.put(state, :mempool, mempool)

      {state, coinbase_transaction} = T.generate_coinbase_transaction(state, transactions)
      transactions = [coinbase_transaction] ++ transactions
      merkle_root = transactions |> MR.get_root()
      block = Map.get(@template, :new_block)
      block = Map.merge(block, %{
        :num_transactions => length(transactions),
        :transactions => transactions
      })

      # IO.inspect transactions

      blockchain = Map.get(state, :blockchain)
      header = Map.get(block, :header)

      pbh = 
        if length(blockchain) == 0 do
          Map.get(header, :previous_block_hash)
        else
          [last_block] = Enum.take(blockchain, -1)
          calculate_block_hash(last_block[:header])
        end

      
      header = Map.merge(header, %{
        :merkle_root => merkle_root,
        :timestamp => DateTime.utc_now(),
        :previous_block_hash => pbh
      })

      nonce = M.mine(header)
      my_address = get_in(state, [:wallet, :public_address])
      IO.puts "A new block mined by #{my_address}"

      header = Map.put(header, :nonce, nonce)
      block = Map.put(block, :header, header)
      blockchain = blockchain ++ [block]
      height = length(blockchain)
      state = Map.put(state, :blockchain, blockchain)
      state = T.update_global_UTXOs(state, coinbase_transaction)
      coinbase_tx_hash = H.transaction_hash(coinbase_transaction, :sha256)
      state = T.update_local_UTXOs(state, coinbase_tx_hash, coinbase_transaction[:outputs])
      
      {state, block, height}
    end

    @doc """
    selects atmost 4 transactions from mempool 
    """
    def select_transactions(mempool, transactions, keys) do
        cond do
            length(transactions) == 4 -> {transactions, keys}
            length(mempool) == 0 -> {transactions, keys}
            true ->
                [{key, transaction} | mempool] = mempool
                select_transactions(mempool, transactions ++ [transaction], keys ++ [key])
        end
    end


    @doc """
    returns the hash of the header of the block
    """
    def calculate_block_hash(header) do
      v = header[:version]
      pbh = header[:previous_block_hash]
      mr = header[:merkle_root]
      t = header[:timestamp]
      n = header[:nonce]

      "#{v}#{pbh}#{mr}#{t}#{n}" |> H.double_hash(:sha256) |> Base.encode16
    end

    @doc """
    receives new block from a neighbor
    """
    def receive(state, block, height) do
      blockchain = state[:blockchain]
      public_address = get_in(state, [:wallet, :public_address])
      IO.puts "A new block received by #{public_address}"
      cond do
        length(blockchain) < height and validate(block) ->
          [coinbase | transactions] = Map.get(block, :transactions)
          mempool = Map.get(state, :mempool)
          mempool = adjust_mempool(mempool, transactions)
          state = Map.put(state, :mempool, mempool)

          state = T.update_global_UTXOs(state, coinbase)

          blockchain = [block] ++ blockchain
          Map.put(state, :blockchain, blockchain)
        length(blockchain) == height and validate(block) ->
          state
        true -> 
          state
      end
      
    end


    @doc """
    updates the mempool
    """
    def adjust_mempool(mempool, transactions) do
      if length(transactions) == 0 do
        mempool
      else
        [transaction | transactions] = transactions
        tx_hash = H.transaction_hash(transaction, :sha256)
        mempool = Map.delete(mempool, tx_hash)
        adjust_mempool(mempool, transactions)
      end
    end



    @doc """
    validates the received block
    """
    def validate(block) do
      validate_syntax(block) and validate_transaction_inclusion(block) 
      and validate_pow(block)

    end

    @doc """
    checks if the block is syntatically correct
    """
    def validate_syntax(block) do
      header = block[:header]

      header[:version] != nil and header[:previous_block_hash] != nil and
      header[:merkle_root] != nil and header[:timestamp] != nil  and 
      header[:bits] != nil and header[:nonce] != nil and 
      block[:num_transactions] > 0 and block[:num_transactions] == length(block[:transactions])
      and map_size(header) == 6 and map_size(block) == 3
    end

    @doc """
    checks if every transaction mentioned in the block is considered
    while calculating the merkle root
    """
    def validate_transaction_inclusion(block) do
      transactions = Map.get(block, :transactions)
      given_merkle_root = get_in(block, [:header, :merkle_root])
      calculated_merkle_root = MR.get_root(transactions)
      given_merkle_root == calculated_merkle_root
    end

    @doc """
    checks if the proof of work was calculated correctly
    """
    def validate_pow(block) do
      header = block[:header]
      nonce = header[:nonce]
      nonce == M.mine(header)
    end

    #@doc """
    #- checks if appropriate coinbase reward was included
    #- checks if only one coinbase transaction is present
    #- checks if the fees has been added properly
    #"""
    # def validate_coinbase(block) do
    #   transactions = Map.get(block, :transactions)
    #   [coinbase | rest] = transactions

    # end

  end
