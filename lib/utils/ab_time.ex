defmodule AnglerBlockchain.AbTime do
  @spec now() :: binary()
  def now(), do: Timex.now() |> Timex.format!("{ISO:Extended}")
end
