defmodule AnglerBlockchain.Blockchain do
  @moduledoc """
  The blockchain.
  """

  use GenServer

  defstruct chain: []
  # Initialization

  @spec start_link(list()) :: {:error, any()} | {:ok, pid()}
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, [name: __MODULE__] ++ opts)
  end

  @leading_hash <<0, 0>>
  @start_nonce 1

  @spec init(any()) :: {:ok, any()}
  def init(state) do
    genesis_block = create_genesis_block(state.chain)
    state = %{state | chain: [genesis_block | state.chain]}

    {:ok, state}
  end

  # API

  @spec chain() :: list()
  def chain(), do: GenServer.call(__MODULE__, :chain)

  @spec verify_chain() :: Bool.t()
  def verify_chain(), do: GenServer.call(__MODULE__, :verify_chain)

  @spec last_block() :: map()
  def last_block(), do: GenServer.call(__MODULE__, :last_block)

  @spec mine_block() :: :ok
  def mine_block(), do: GenServer.cast(__MODULE__, :mine_block)

  # Callbacks

  def handle_call(:chain, _from, %{chain: chain} = state), do: {:reply, chain, state}

  def handle_call(:last_block, _from, %{chain: chain} = state), do: {:reply, List.last(chain), state}

  def handle_call(:verify_chain, _from, %{chain: chain} = state) do
    {:reply, chain_is_coherent?(nil, chain |> Enum.reverse()), state}
  end

  def handle_cast(:mine_block, %{chain: chain} = state) do
    last_block_hash =
      chain
      |> List.first()
      |> calc_hash()
      |> Base.encode16()

    new_block =
      chain
      |> init_block(last_block_hash)
      |> start_mine_block()

    {:noreply, %{state | chain: [new_block | chain]}}
  end

  #def handle_info({:baz, [value]}, state) do
  #  {:noreply, state}
  #end

  # Helpers

  defp init_block(chain, previous_hash) do
    next_index = length(chain) + 1
    AnglerBlockchain.Block.create(next_index, previous_hash)
  end

  defp create_genesis_block(chain) do
    IO.write "Initializing blockchain: mining genesis block... "
    genesis_block =
      init_block(chain, "0000000000000000000000000000000000000000000000000000000000000000")
      |> start_mine_block()
    IO.puts "done."

    genesis_block
  end

  @spec start_mine_block(AnglerBlockchain.Block.t()) :: AnglerBlockchain.Block.t()
  defp start_mine_block(block), do: mine(block, "", @start_nonce)

  defp mine(block, @leading_hash <> _, _nonce), do: block
  defp mine(block, _hash, nonce) do
    block = %{block | nonce: nonce}
    hash = calc_hash(block)
    mine(block, hash, nonce + 1)
  end

  defp chain_is_coherent?(nil, []), do: true
  defp chain_is_coherent?(nil, [block | tail]), do: chain_is_coherent?(block, tail)
  defp chain_is_coherent?(block, [next_block | tail]) do
    case blocks_are_coherent?(block, next_block) do
      true  -> chain_is_coherent?(next_block, tail)
      _     -> false
    end
  end
  defp chain_is_coherent?(block, []) do
    blocks_are_coherent?(block, nil)
  end

  defp blocks_are_coherent?(block, nil) do
    block |> calc_hash() |> mined_hash?()
  end

  defp blocks_are_coherent?(block, next_block) do
    hash = block |> calc_hash()
    (Base.encode16(hash) == next_block.previous_hash) and mined_hash?(hash)
  end

  defp mined_hash?(@leading_hash <> _), do: true
  defp mined_hash?(_hash), do: false

  defp calc_hash(block), do: :crypto.hash(:sha256, block |> Poison.encode!())
end
