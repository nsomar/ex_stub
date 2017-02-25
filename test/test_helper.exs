defmodule OriginalModule do
  def process(%{cool: 1}), do: :old1
  def process(%{cool: 2}), do: :old2
  def process(%{cool: 3}), do: :old3

  def sing(%{cool: 3}), do: :old3

  def method1, do: :method1
end

ExUnit.start()
