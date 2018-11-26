defmodule Block do

    @doc """
    creates block from the given transactions
    """
    def create_block() do
        block = %{ :blockHash => nil,
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
        mTree(list1,list2,size)
    end

    @doc """
    returns merkel root or hash codes the hashes formed from the previous iteration.
    """
    def mTree([],list2,0) do
        if(length(list2) <= 1) do
            #IO.puts "returning merkel root"
            list2
        else
            mTree(list2,[],length(list2))
        end
    end

    @doc """
    called when self-hashing is required.
    """
    def mTree(list,list2,1) do
        [head | tail] = list
        h = :crypto.hash(:sha256, "#{head}#{head}") |> Base.encode16
        h = [:crypto.hash(:sha256, "#{h}") |> Base.encode16]
        clist = list2 ++ h
        mTree(tail,clist,length(tail))
    end

    @doc """
    called when size > 1
    """
    def mTree(list,list2,size) do
        #IO.puts "in 2"
        [x,y | tail] = list
        h = :crypto.hash(:sha256, "#{x}#{y}") |> Base.encode16
        h = [:crypto.hash(:sha256, "#{h}") |> Base.encode16]
        #IO.inspect h
        clist = list2 ++ h
        if(tail != []) do
            mTree(tail,clist,length(tail))
        else
            mTree([],clist,0)
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
        blockHash = block[:blockHash]

        result = check(version,previousblock,merkelroot,time,bits,nonce,blockHash)
        result
    end

    defp check(version,previousblock,merkelroot,time,bits,nonce,blockHash) do
        ha = :crypto.hash(:sha256,"#{version}#{previousblock}#{merkelroot}#{time}#{nonce}")|>Base.encode16
        ha = :crypto.hash(:sha256,ha) |> Base.encode16
        blockHash == ha
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
