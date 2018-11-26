defmodule Mining do

    def mine(block) do
        version = block[:version]
        previousblock = block[:previousblock]
        merkelroot = block[:merkelroot]
        time = block[:time]
        bits = block[:bits]
        nonce = block[:nonce]

        proofOfwork(version,previousblock,merkelroot,time,bits,nonce)
    end

    def proofOfwork(version,previousblock,merkelroot,time,bits,nonce) do
        ha = :crypto.hash(:sha256,"#{version}#{previousblock}#{merkelroot}#{time}#{nonce}")|>Base.encode16
        IO.inspect ha

        if(ha < bits) do
            ha
        else
            nonce = nonce+1
            proofOfwork(version,previousblock,merkelroot,time,bits,nonce)
        end
    end

    # def test do
    #     h = :crypto.hash(:sha256, "1")
    #     mr = :crypto.hash(:sha256, "2")
    #   m = %{:version => 1458,
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