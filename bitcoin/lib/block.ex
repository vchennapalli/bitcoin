defmodule Block do

#Block structure
    def createBlock() do
        block = %{ :blockHash: nil,
        :version: 1, 
        :previousblock: nil , 
        :merkelroot: nil ,
        :time: DateTime.utc_now(), 
        :bits: nil, 
        :nonce: 0,
        :transactions: []
        }
        block

    end

#CreateMtree function returns the root of the merkel tree formed by the transactions.
    def createMTree(list1) do
        list2 = []
        size = length(list1)
        mTree(list1,list2,size)
    end

#Returns merkel root or hash codes the hashes formed from the previous iteration.
    def mTree([],list2,0) do
        if(length(list2) <= 1) do
            #IO.puts "returning merkel root"
            list2
        else
            mTree(list2,[],length(list2))
        end
    end

#Called when hashing with itself is required.
    def mTree(list,list2,1) do
        #IO.puts "in 1"
        [head | tail] = list
        h = :crypto.hash(:sha256, "#{head}#{head}") |> Base.encode16
        h = [:crypto.hash(:sha256, "#{h}") |> Base.encode16]
        clist = list2 ++ h
        mTree(tail,clist,length(tail))
    end

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

    # def test() do
    #     list = [1,2,3]
    #     createMTree(list)
    # end


end