defmodule WatchMake.Util do
  def indent(s, prefix) do
    s
    |> String.split("\n")
    |> Enum.map(&(prefix <> &1))
    |> Enum.join("\n")
  end
end
