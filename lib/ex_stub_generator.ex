defmodule ExStub.Generator do
  @moduledoc """
  Provide functions to generate a forwarding function, and the stub module
  """

  @doc """
  Create a forwarding method
  """
  def create_method({_, _, [{func_name, _, nil}| _]}, module),
    do: create_method(func_name, 0, module)

  def create_method({_, _, [{func_name, _, params}| _]}, module),
    do: create_method(func_name, params |> Enum.count, module)

  def create_method(func_name, params, module) do
    func_params = create_params(params)
    """
    def #{func_name}#{func_params} do
      #{module}.#{func_name}#{func_params}
    end
    """
  end

  defp create_params(0), do: "()"
  defp create_params(num) do
    params =
        1..num
        |> Enum.map(fn num ->
          "a#{num}"
        end)
    "(#{Enum.join(params, ", ")})"
  end

  @doc """
  Generate the stub module
  """
  def generate_stub_module(stub_name, functions) do
    """
    defmodule #{stub_name} do
    #{functions}
    end
    """
  end

  @doc """
  Generate all the forwarding functions
  """
  def generate_forwarding_functions(functions, module) do
    functions
    |> Enum.map(fn
      {func_name, ar} ->
        create_method(func_name, ar, module)
    end)
  end

  @doc """
  Convert module from string to AST
  """
  def module_ast(module) do
    {:ok, module_ast} = Code.string_to_quoted(module)
    module_ast
  end
end
