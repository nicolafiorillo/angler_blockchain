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

  @spec init(any()) :: {:ok, any()}
  def init(state) do
    next_index = length(state.chain) + 1
    genesis_block = AnglerBlockchain.Block.create(next_index, 1, "0")
    state = %{state | chain: [genesis_block | state.chain]}

    {:ok, state}
  end

  # API

  @spec chain() :: list()
  def chain(), do: GenServer.call(__MODULE__, :chain)

  @spec last_block() :: map()
  def last_block(), do: GenServer.call(__MODULE__, :last_block)

  # Callbacks

  def handle_call(:chain, _from, %{chain: chain} = state) do
   {:reply, chain, state}
  end

  def handle_call(:last_block, _from, %{chain: chain} = state) do
    {:reply, List.last(chain), state}
   end

  #def handle_cast({:bar, [value]}, state) do
  #  {:noreply, state}
  #end

  #def handle_info({:baz, [value]}, state) do
  #  {:noreply, state}
  #end

  # Helpers

end
