defmodule AnglerBlockchain.Mempool do
  @moduledoc """
  The local mempool: a repository for unconfirmed transactions.
  """

  use GenServer
  alias AnglerBlockchain.Transaction

  defstruct transactions: []
  # Initialization

  @spec start_link(list()) :: {:error, any()} | {:ok, pid()}
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, [name: __MODULE__] ++ opts)
  end

  @spec init(nil) :: {:ok, any()}
  def init(nil) do
    {:ok, %__MODULE__{}}
  end

  # API

  @spec add_transaction(binary(), binary(), number()) :: {:error, any()} | :ok
  def add_transaction(sender, receiver, amount) do
    GenServer.call(__MODULE__, {:add_transaction, %{sender: sender, receiver: receiver, amount: amount}})
  end

  @spec list_transactions() :: List.t()
  def list_transactions(), do: GenServer.call(__MODULE__, :list_transactions)

  #def bar(value) do
  #  GenServer.cast(__MODULE__, {:bar, [value]})
  #end

  # Callbacks

  def handle_call({:add_transaction, %{sender: sender, receiver: receiver, amount: amount}}, _from, %{transactions: transactions} = state) do
    transactions = [Transaction.new(sender, receiver, amount) | transactions]
    {:reply, :ok, %{state | transactions: transactions}}
  end

  def handle_call(:list_transactions, _from, %{transactions: transactions} = state), do: {:reply, transactions, state}

  #def handle_cast({:bar, [value]}, state) do
  #  {:noreply, state}
  #end

  #def handle_info({:baz, [value]}, state) do
  #  {:noreply, state}
  #end

  # Helpers

end
