defmodule AnglerBlockchain.ProofOfWork do

  @leading_hash <<0, 0>>
  @start_nonce 1

  alias AnglerBlockchain.Block

  @spec mine_new_block([Block.t()]) :: Block.t()
  def mine_new_block(chain) do
    last_block_hash =
      chain
      |> List.first()
      |> calc_hash()
      |> Base.encode16()

    chain
    |> init_block(last_block_hash)
    |> start_mine_block()
  end

  @spec create_genesis_block([Block.t()]) :: Block.t()
  def create_genesis_block(chain) do
    init_block(chain, "0000000000000000000000000000000000000000000000000000000000000000")
    |> start_mine_block()
  end

  @spec init_block([Block.t()], binary()) :: Block.t()
  def init_block(chain, previous_hash) do
    next_index = length(chain) + 1
    Block.create(next_index, previous_hash)
  end

  @spec start_mine_block(Block.t()) :: Block.t()
  def start_mine_block(block), do: mine(block, "", @start_nonce)

  @spec mine(Block.t(), binary(), number()) :: Block.t()
  def mine(block, @leading_hash <> _, _nonce), do: block
  def mine(block, _hash, nonce) do
    block = %{block | nonce: nonce}
    hash = calc_hash(block)
    mine(block, hash, nonce + 1)
  end

  def mined_hash?(@leading_hash <> _), do: true
  def mined_hash?(_hash), do: false

  def block_is_coherent?(block, nil) do
    block |> calc_hash() |> mined_hash?()
  end
  def block_is_coherent?(block, next_block) do
    hash = block |> calc_hash()
    (Base.encode16(hash) == next_block.previous_hash) and mined_hash?(hash)
  end

  defp calc_hash(block), do: :crypto.hash(:sha256, block |> Poison.encode!())
end
