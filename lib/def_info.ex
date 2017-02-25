defmodule DefInfo do
  @moduledoc """
  Function info
  """
  defstruct [:name, :params, :catches_all, :arity]

  @doc """
  Parse a def to a definfo
  """
  def parse({:def, _, [{name, _, params} | _]}) do
    %DefInfo{
      name: name,
      params: params,
      arity: arity(params),
      catches_all: catches_all?(params)
    }
  end

  @doc """
  Get the def arity
  """
  def arity(nil), do: 0
  def arity(params), do: params |> Enum.count

  @doc """
  Is the def a catch all def
  """
  def catches_all?(nil), do: true
  def catches_all?([]), do: true
  def catches_all?(params) do
    Enum.all?(params, fn param -> param_type(param) == :free_param end)
  end

  @doc """
  Convert dif to name and arity
  """
  def name_arity(%{name: name, arity: arity}), do: {name, arity}

  defp param_type({_, _, nil}), do: :free_param
  defp param_type(_), do: :not_free_param

end
