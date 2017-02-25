defmodule ExStub do
  @moduledoc """
  ExStub provides an easy way to stub a module and enrich it with extra methods

  ## Example:

  If you have a module in your original application like:

  ```elixir
  defmodule OriginalModule do
    def process(param), do: :original_process
    def another_method, do: :original_method
  end
  ```

  You can quickly create a stub copy of this module using `defstub`

  ```elixir
  defstub MyStub, for: OriginalModule do
    def process(true), do: :stubbed1
    def process(false), do: :stubbed2
    def process(1), do: :stubbed3
  end
  ```

  Now you can pass around `MyStub` instead of `OriginalModule`.
  When you invoke method from the created `MyStub`, if the method was stubbed it will call the stubbed version.
  Else the original version will be called.

  ```elixir
  MyStub.process(true) # returns :stubbed1
  MyStub.process(false) # returns :stubbed2
  MyStub.process(1) # returns :stubbed3

  MyStub.another_method # returns :original_method
  ```

  Since we did not stub `another_method`, calling it on `MyStub` returns the original implementation.
  """

  defmacro __using__(_) do
    quote do
      import ExStub
    end
  end

  @doc """
  `defstub` provides a way to create a stub module.

  ## Usage

  If you have a module that you want to stub in your app

  ```elixir
  defmodule OriginalModule do
    def process(param), do: :original_process
    def another_method, do: :original_method
  end
  ```

  You can call `defstub` to stub it

  ```elixir
  defstub MyStub, for: OriginalModule do
    def process(true), do: :stubbed1
    def process(false), do: :stubbed2
    def process(1), do: :stubbed3
  end
  ```

  As a safety procedure, if you try to stub a method that is not found in the original module. ExStub will throw a compilation error telling you about the unexpected stubbed method.

  Example

  ```elixir
  defstub MyStub, for: OriginalModule do
    def new_method(), do: :stubbed1
  end
  ```

  The following error will be thrown

  ```
  ** (RuntimeError) Cannot provide implementations for methods that are not in the original module
  The def `{:new_method, 0}` is not defined in module `OriginalModule`
  ```
  """
  defmacro defstub(ast_module_name, [for: ast_original_module_name], [do: block]) do
    # Get the module names
    original_module_name = module_name_from_ast(ast_original_module_name)
    stub_module_name = module_name_from_ast(ast_module_name)

    # The functions in the original modules
    module_functions = original_module_functions(original_module_name)

    # The functions in the stub module
    stub_functions = ExStub.Utils.functions_passed(block)
    prepared_stub_functions = ExStub.Utils.functions_and_params(stub_functions)

    # Check that all the stub functions exist in the original module
    ExStub.Utils.check_all_functions_exist(prepared_stub_functions, module_functions, original_module_name)

    # The functions that will forward the implementation to the original module
    catch_all_to_add = ExStub.Utils.catch_all_functions(module_functions, prepared_stub_functions)

    # The stubbed functions plus the functions that forwawrd to the the original module
    all_stubbed_functions =
    ExStub.Utils.stub_functions_with_catch_all(stub_functions, catch_all_to_add, original_module_name)
    |> Macro.to_string

    # The functions in the original module that are not stubbed
    non_stubbed_functions =
    module_functions
    |> ExStub.Utils.non_exisiting_functions(prepared_stub_functions)
    |> ExStub.Generator.generate_forwarding_functions(original_module_name)

    # All the functions in the stubbed module
    all_functions = "#{all_stubbed_functions}\n#{non_stubbed_functions}"

    # The generated stub module
    stub_module_ast =
    stub_module_name
    |> ExStub.Generator.generate_stub_module(all_functions)
    |> ExStub.Generator.module_ast

    # stub_module_ast |> Macro.to_string |> IO.puts

    stub_module_ast
  end

  defp module_name_from_ast(ast_module_name), do: Code.eval_quoted(ast_module_name) |> elem(0)

  defp original_module_functions(module) do
    :"#{module}".__info__(:functions)
  end

end
