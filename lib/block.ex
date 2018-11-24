defmodule AnglerBlockchain.Block do

  alias AnglerBlockchain.AbTime

  defstruct index: nil, timestamp: nil, proof: nil, prev_hash: nil

  @spec create(Int.t(), String.t(), String.t()) :: Map.t()
  def create(index, proof, prev_hash) do
    %__MODULE__{
      index: index,
      timestamp: AbTime.now(),
      proof: proof,
      prev_hash: prev_hash
    }
  end
end
