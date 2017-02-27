defmodule ExStub.Recorder do
  @moduledoc """
  `ExStub.Recorder` Provides methods to record the function calls and provides a set of functions to query the recorded executions.
  """

  use GenServer

  def handle_call(:init, _, _) do
    res = :ets.new(__MODULE__, [:duplicate_bag, :protected, :named_table])
    {:reply, res, []}
  end

  def handle_call({:record, module, name, params}, _, _) do
    :ets.insert(__MODULE__, {module, name, params})
    {:reply, [], []}
  end

  def handle_call({:state, module}, _, _) do
    res = :ets.match_object(__MODULE__, {module, :"_", :"_"})
    |> prepare_return
    {:reply, res, []}
  end

  def handle_call({:state, module, func}, _, _) do
    res = :ets.match_object(__MODULE__, {module, func, :"_"})
    |> prepare_return
    {:reply, res, []}
  end

  def handle_call({:state, module, func, params}, _, _) do
    res = :ets.match_object(__MODULE__, {module, func, params})
    |> prepare_return
    {:reply, res, []}
  end

  @doc """
  Start the recording session. (Not to be called manually)
  """
  def start_recording do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], name: __MODULE__)
    GenServer.call(__MODULE__, :init)
    pid
  end

  @doc """
  Record a funtion call on a module with params.
  """
  def record_call(module, name, params) do
    if Process.whereis(__MODULE__) == nil do
      __MODULE__.start_recording
    end

    GenServer.call(__MODULE__, {:record, module, name, params})
  end

  @doc """
  Get all the function calls on a specific module.

  ## Example
  ```
  MyStub.func1
  MyStub.func2

  ExStub.Recorder.calls(MyStub)
  ```
  This returns [func1: [], func2: []]
  """
  def calls(module) do
    call_if_possible({:state, module})
  end

  @doc """
  Get all the function calls on a specific module that match a function name.

  ## Example
  ```
  MyStub.func1([1])
  MyStub.func2([1, 2])

  ExStub.Recorder.calls(MyStub, :func2)
  ```
  This returns [func1: [1]]
  """
  def calls(module, function) do
    call_if_possible({:state, module, function})
  end

  @doc """
  Get all the function calls on a specific module that match a function name and list of params.

  ## Example
  ```
  MyStub.func1([1])
  MyStub.func1([2])

  ExStub.Recorder.calls(MyStub, :func2, [1])
  ```
  This returns [func1: [1]]
  """
  def calls(module, function, params) do
    {:state, module, function, params}
    call_if_possible({:state, module, function, params})
  end

  defp call_if_possible(params) do
    if Process.whereis(__MODULE__) == nil do
      []
    else
      GenServer.call(__MODULE__, params)
    end
  end

  defp prepare_return(results) do
    Enum.map(results, fn {_, func, params} -> {func, params} end)
  end
end
