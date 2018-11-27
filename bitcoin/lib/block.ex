defmodule Block do

    @doc """
    creates block from the given transactions
    """
    def create_block() do
        block = %{ :blockhash => nil,
        :version => 1,
        :previousblock => "0000000000000000000000000000000000000000000000000000000000000000",
        :merkelroot => nil ,
        :time => DateTime.utc_now(),
        :bits => "00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        :nonce => 0,
        :transactions => []
        }
        block
    end

    @doc """
    returns the root of the merkel tree formed by the transactions.
    """
    def create_merkle_tree(list1) do
        list2 = []
        size = length(list1)
        create_merkle_levels(list1,list2,size)
    end

    @doc """
    returns merkel root or hash codes the hashes formed during the previous iteration.
    """
    def create_merkle_levels([],list2,0) do
        if(length(list2) <= 1) do
            #IO.puts "returning merkel root"
            list2
        else
            create_merkle_levels(list2,[],length(list2))
        end
    end

    @doc """
    called when self-hashing is required.
    """
    def create_merkle_levels(list,list2,1) do
        [head | tail] = list
        h = :crypto.hash(:sha256, "#{head}#{head}") |> Base.encode16
        h = [:crypto.hash(:sha256, "#{h}") |> Base.encode16]
        clist = list2 ++ h
        create_merkle_levels(tail,clist,length(tail))
    end

    @doc """
    called when size > 1
    """
    def create_merkle_levels(list,list2,size) do
        #IO.puts "in 2"
        [x,y | tail] = list
        h = :crypto.hash(:sha256, "#{x}#{y}") |> Base.encode16
        h = [:crypto.hash(:sha256, "#{h}") |> Base.encode16]
        #IO.inspect h
        clist = list2 ++ h
        if(tail != []) do
            create_merkle_levels(tail,clist,length(tail))
        else
            create_merkle_levels([],clist,0)
        end
    end

    @doc """
    verifies whether a valid block was created or not
    """
    def verify_block(block) do
        version = block[:version]
        previousblock = block[:previousblock]
        merkelroot = block[:merkelroot]
        time = block[:time]
        bits = block[:bits]
        nonce = block[:nonce]
        blockhash = block[:blockhash]

        check(version,previousblock,merkelroot,time,bits,nonce,blockhash)
    end

    defp check(version,previousblock,merkelroot,time,bits,nonce,blockhash) do
        ha = :crypto.hash(:sha256,"#{version}#{previousblock}#{merkelroot}#{time}#{nonce}")|>Base.encode16
        blockhash == :crypto.hash(:sha256,ha) |> Base.encode16 and blockhash <= bits
    end

# Test block which created a sample block for testing.
    def testblock() do
        h = :crypto.hash(:sha256, "previous hash code")
        mr = :crypto.hash(:sha256, "merkel root header")
        m = %{ :blockHash => nil,
        :version => 1,
        :previousblock => h ,
        :merkelroot => mr ,
        :time => DateTime.utc_now(),
        #:bits => 1d00ffff
        :bits => "00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        :nonce => 0,
        :transactions => []
      }
      m
    end

     # def test() do
    #     list = [1,2,3]
    #     createMTree(list)
    # end

    # def test do
    #     h = :crypto.hash(:sha256, "previous hash code")
    #     mr = :crypto.hash(:sha256, "merkel root header")
    #     m = %{ :blockHash => nil,
    #     :version => 1,
    #     :previousblock => h ,
    #     :merkelroot => mr ,
    #     :time => DateTime.utc_now(),
    #     #:bits => 1d00ffff
    #     :bits => "003fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
    #     :nonce => 0,
    #     :transactions => []
    #   }
    #   block = Mining.mine(m)

    #   verifyBlock(block)

    # end
end
