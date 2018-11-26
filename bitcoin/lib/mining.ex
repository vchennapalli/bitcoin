defmodule Mining do

#Extrcting the block details and mining the proof of work and updating nonce
    def mine(block) do
        version = block[:version]
        previousblock = block[:previousblock]
        merkelroot = block[:merkelroot]
        time = block[:time]
        bits = block[:bits]
        nonce = block[:nonce]

        data = proofOfwork(version,previousblock,merkelroot,time,bits,nonce)
        
        hash= Enum.at(data,0)
        nonce = Enum.at(data,1)
        
        block = Map.put(block,:blockHash,hash)
        block = Map.put(block,:nonce,nonce)
        
        # IO.puts "#{block[:blockHash]}#{block[:nonce]}"
        block

    end

    #For mining the block
    def proofOfwork(version,previousblock,merkelroot,time,bits,nonce) do
        ha = :crypto.hash(:sha256,"#{version}#{previousblock}#{merkelroot}#{time}#{nonce}")|>Base.encode16
        ha = :crypto.hash(:sha256,ha) |> Base.encode16
        
        if(ha < bits) do
            [ha,nonce]
        else
            nonce = nonce+1
            proofOfwork(version,previousblock,merkelroot,time,bits,nonce)
        end
    end

    # def test() do
    #     h = :crypto.hash(:sha256, "1")
    #     mr = :crypto.hash(:sha256, "2")
    #   m = %{ :blockHash => nil,
    #     :version => 1458,
    #     :previousblock => h , 
    #     :merkelroot => mr ,
    #     :time => DateTime.utc_now(), 
    #     #:bits => 1d00ffff
    #     :bits => "003fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", 
    #     :nonce => 0,
    #     :transactions => []
    #   }
    #   mine(m)
    # end
end