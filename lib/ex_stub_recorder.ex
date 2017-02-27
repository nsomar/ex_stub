defmodule ExStub.Recorder do
  use GenServer

  def start_recording do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], name: __MODULE__)
    GenServer.call(__MODULE__, :init)
    pid
  end

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

  def record_call(module, name, params) do
    if Process.whereis(__MODULE__) != nil do
      GenServer.call(__MODULE__, {:record, module, name, params})
    end
  end

  def calls(module) do
    call_if_possible({:state, module})
  end

  def calls(module, function) do
    call_if_possible({:state, module, function})
  end

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
