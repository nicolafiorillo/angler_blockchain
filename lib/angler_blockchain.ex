defmodule AnglerBlockchain.Blockchain do
  @moduledoc """
  The blockchain.
  """

  use GenServer
  alias AnglerBlockchain.ProofOfWork
  require Logger

  defstruct chain: []

  # Initialization

  @spec start_link(list()) :: {:error, any()} | {:ok, pid()}
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, [name: __MODULE__] ++ opts)
  end

  @spec init(any()) :: {:ok, any()}
  def init(state) do
    Logger.info("Initializing blockchain: mining genesis block.")
    genesis_block = ProofOfWork.create_genesis_block(state.chain)
    Logger.info("Mined genesis block on chain.")

    {:ok, %{state | chain: [genesis_block | state.chain]}}
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

  def handle_call(:last_block, _from, %{chain: chain} = state),
    do: {:reply, List.last(chain), state}

  def handle_call(:verify_chain, _from, %{chain: chain} = state) do
    {:reply, chain_is_coherent?(nil, chain |> Enum.reverse()), state}
  end

  def handle_cast(:mine_block, %{chain: chain} = state) do
    Logger.info("Mining new block.")
    new_block = ProofOfWork.mine_new_block(chain)
    Logger.info("New mined block on chain.")
    {:noreply, %{state | chain: [new_block | chain]}}
  end

  # def handle_info({:baz, [value]}, state) do
  #  {:noreply, state}
  # end

  # Helpers

  defp chain_is_coherent?(nil, []), do: true
  defp chain_is_coherent?(nil, [block | tail]), do: chain_is_coherent?(block, tail)

  defp chain_is_coherent?(block, [next_block | tail]) do
    case ProofOfWork.block_is_coherent?(block, next_block) do
      true -> chain_is_coherent?(next_block, tail)
      _ -> false
    end
  end

  defp chain_is_coherent?(block, []), do: ProofOfWork.block_is_coherent?(block, nil)
end
