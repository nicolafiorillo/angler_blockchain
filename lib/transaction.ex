defmodule AnglerBlockchain.Transaction do

  defstruct sender: nil, receiver: nil, amount: 0

  @spec new(binary(), binary(), number()) :: Map.t()
  def new(sender, receiver, amount) do
    %__MODULE__{sender: sender, receiver: receiver, amount: amount}
  end
end
