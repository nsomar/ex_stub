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
    call = recording_call(func_name, params) |> Macro.to_string
    """
    def #{func_name}(#{func_params}) do
      #{call}
      #{module}.#{func_name}(#{func_params})
    end
    """
  end

  defp create_params(0), do: ""
  defp create_params(num) do
    params =
        1..num
        |> Enum.map(fn num ->
          "p#{num}__"
        end)
    "#{Enum.join(params, ", ")}"
  end

  def recording_call(func, params) do
    {:ok, param_string} = "[#{create_params(params)}]" |> Code.string_to_quoted
    quote do
      __MODULE__.__record_call__(unquote(func), unquote(param_string))
    end
  end

  @doc """
  Generate the stub module
  """
  def generate_stub_module(stub_name, functions) do
    """
    defmodule #{stub_name} do
    #{gen_server_functions}
    #{functions}
    end
    """
  end

  defp gen_server_functions do
    """
    def __record_call__(name, params) do
      ExStub.Recorder.record_call(__MODULE__, name, params)
    end

    def __calls__ do
      ExStub.Recorder.calls(__MODULE__)
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
