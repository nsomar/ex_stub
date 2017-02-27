defmodule ExStub.Assert do
  @moduledoc """
  This module provides the `assert_called` that can be used to assert functions calls on your stubs.
  This module is already required and imported when using `use ExStub`
  """

  @doc """
  Asserts that the function was called on the module with the passed params

  ## Example

  ```elixir
  defstub MyStub, for: OriginalModule do
    def process(1), do: :stubbed3
  end

  MyStub.process(1)

  # Passes since we called the function with [1]
  assert_called MyStub, process, with: [1]

  # Fails since the parameters dont match
  assert_called MyStub, process, with: [1, 2]

  # Fails since we did not call `another_method`
  assert_called MyStub, another_method, with: []
  ```
  """
  defmacro assert_called(module, function, [with: params]) do
    mod_name = module_name_from_ast(module)
    func_name = function_name(function)

    quote do
      res = check_called(unquote(mod_name),unquote(func_name), unquote(params))
      if res != :ok do
        flunk res
      end
    end
  end

  def check_called(mod_name, func_name, params) do
    ExStub.Recorder.calls(mod_name, func_name, params)
    |> check_success(mod_name, func_name, params)
  end

  defp check_success([], mod_name, func_name, params) do
    "Expected call to `#{inspect(mod_name)}.#{func_name |> Atom.to_string}` with #{inspect(params)} was not recorded"
  end

  defp check_success(_, _, _, _) do
    :ok
  end

  defp module_name_from_ast(ast_module_name), do: Code.eval_quoted(ast_module_name) |> elem(0)
  defp function_name({name, _, _}), do: name

end
