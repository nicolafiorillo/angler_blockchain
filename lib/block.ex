defmodule AnglerBlockchain.Block do
  alias AnglerBlockchain.AbTime

  defstruct index: nil, timestamp: nil, nonce: 0, previous_hash: nil

  @spec create(number(), binary()) :: Map.t()
  def create(index, previous_hash) do
    %__MODULE__{
      index: index,
      timestamp: AbTime.now(),
      previous_hash: previous_hash
    }
  end
end
