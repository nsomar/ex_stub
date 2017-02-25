defmodule ExStub.Utils do
  @moduledoc """
  ExStub utilitie class
  """

  @doc """
  Gets the functions passed to the stub
  """
  def functions_passed({:__block__, _, functions}), do: functions
  def functions_passed(nil), do: []
  def functions_passed(functions), do: [functions]

  @doc """
  Convert the list of defs to DefInfo
  """
  def functions_and_params(functions) do
    Enum.map(functions, &DefInfo.parse/1)
  end

  @doc """
  Get the functions that done exisit in the stub module
  """
  def non_exisiting_functions(module_functions, stub_functions) do
    module_functions
    |> Enum.filter(fn func -> !stub_funcs_contains_func(stub_functions, func) end)
  end

  @doc """
  Get the functions that dont have a catch all in the stub module
  """
  def catch_all_functions(module_functions, stub_functions) do
    catch_all_funcs = Enum.filter(stub_functions, fn func -> func.catches_all == true end)

    module_functions
    |> Enum.filter(fn func -> stub_funcs_contains_func(stub_functions, func) end)
    |> Enum.filter(fn func -> !stub_funcs_contains_func(catch_all_funcs, func) end)
  end

  defp stub_funcs_contains_func(stub_functions, {name, arity}) do
    Enum.any?(stub_functions, fn stub_function ->
      stub_function.name == name && stub_function.arity == arity
    end)
  end

  @doc """
  Check that all the stub functions exist in the original module
  """
  def check_all_functions_exist(stub_functions, module_functions, module) do
    stub_functions = Enum.map(stub_functions, &DefInfo.name_arity/1)

    Enum.map(stub_functions, fn func ->
      is_member = Enum.member?(module_functions, func)
      throw_exception_if_needed(is_member, func, module)
    end)
  end

  defp throw_exception_if_needed(false, func, module) do
    desc = """
          Cannot provide implementations for methods that are not in the original module
          The def `#{inspect(func)}` is not defined in module `#{inspect(module)}`
          """
    raise desc
  end

  defp throw_exception_if_needed(_, _, _), do: true

  ##########################################################################################
  # Catch all
  ##########################################################################################

  def stub_functions_with_catch_all(stub_functions, catch_all_to_add, module) do
    stub_functions_with_catch_all(Enum.reverse(stub_functions), [], catch_all_to_add, module)
  end

  # Last
  defp stub_functions_with_catch_all([], acc, _, _) do
    acc |> Enum.reverse
  end

  # First
  defp stub_functions_with_catch_all([h| tail], acc, to_add, module) do
    info = DefInfo.parse(h)
    name_arity = DefInfo.name_arity(info)
    updated_list = update_funcst_to_add(to_add, name_arity)

    {functions, remaining_to_add} = create_method_and_append_it(h, module, updated_list)
    # |> IO.inspect

    stub_functions_with_catch_all(tail,
                                acc ++ functions,
                                remaining_to_add,
                                module
                                )
  end

  defp create_method_and_append_it(current, module, {:ok, to_add}) do
    {:ok, created} = ExStub.Generator.create_method(current, module) |> Code.string_to_quoted
    {[created, current], to_add}
  end

  defp create_method_and_append_it(current, _, {:not_found, to_add}) do
    {[current], to_add}
  end

  defp update_funcst_to_add(to_add, func) do
    if Enum.member?(to_add, func) do
      {:ok, List.delete(to_add, func)}
    else
      {:not_found, to_add}
    end
  end
end
