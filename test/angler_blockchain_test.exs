defmodule AnglerBlockchainTest do
  use ExUnit.Case

  alias AnglerBlockchain.Blockchain

  test "create blockchain, mine and verify" do
    1..5 |> Enum.each(fn _ -> Blockchain.mine_block() end)

    chain = Blockchain.chain()
    assert length(chain) == 6

    assert Blockchain.verify_chain()
  end
end
