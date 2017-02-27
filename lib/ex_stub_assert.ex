defmodule ExStub.Assert do

  defmacro assert_called(mod_ast, func_ast, [with: params]) do
    mod_name = module_name_from_ast(mod_ast)
    func_name = function_name(func_ast)

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
