defmodule Mining do
    alias Helper, as: H
    @doc """
    takes in a new block and returns the block with its nonce
    """
    def mine(header) do
        version = header[:version]
        previous_block_hash = header[:previous_block_hash]
        merkle_root = header[:merkle_root]
        timestamp = header[:timestamp]
        bits = header[:bits]
        nonce = header[:nonce]
        generate_proof_of_work(version, previous_block_hash, merkle_root, timestamp, bits, nonce)
    end

    @doc """
    recursive method that generates the appropriate nonce
    """
    def generate_proof_of_work(v, pbh, mr, t, bits, n) do
        
        hash = "#{v}#{pbh}#{mr}#{t}#{n}" |> H.double_hash(:sha256) |> Base.encode16

        # receive do
        #     {:receive_transaction, new_transaction} ->
        # end
        
        if(hash < bits) do
            n
        else
            n = n + 1
            generate_proof_of_work(v, pbh, mr, t, bits, n)
        end
    end

end