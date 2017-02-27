use ExStub

defmodule ExStubRecorderTest do
  use ExUnit.Case

  test "can get calls from a mod" do
    ExStub.Recorder.start_recording
    ExStub.Recorder.record_call(ExUnit, :method1, [1, 2])

    assert ExStub.Recorder.calls(ExUnit) ==
    [method1: [1, 2]]
  end

  test "can get calls from a mod and func" do
    ExStub.Recorder.start_recording
    ExStub.Recorder.record_call(ExUnit, :method1, [1, 2])
    assert ExStub.Recorder.calls(ExUnit, :method1) ==
    [method1: [1, 2]]
  end

  test "can get calls from a mod, func and params" do
    ExStub.Recorder.start_recording
    ExStub.Recorder.record_call(ExUnit, :method1, [1, 2])
    assert ExStub.Recorder.calls(ExUnit, :method1, [1, 2]) ==
    [method1: [1, 2]]
  end

  test "returns empty if call is not found" do
    ExStub.Recorder.start_recording
    ExStub.Recorder.record_call(ExUnit, :method1, [1, 2])
    assert ExStub.Recorder.calls(ExUnit, :method2) ==
    []
  end

  test "it can use with asserts" do
    ExStub.Recorder.start_recording
    ExStub.Recorder.record_call(ExUnit, :method1, [1, 2])
    assert_called ExUnit.method1(1, 2)
  end

  test "it returns correct error when fails" do
    ExStub.Recorder.start_recording
    ExStub.Recorder.record_call(ExUnit, :method1, [1, 2])

    assert ExStub.Assert.check_called(ExUnit, :method1, [1, 2]) ==
    :ok

    assert ExStub.Assert.check_called(ExUnit, :method1, [1, 2, 3]) ==
    "Expected call to `ExUnit.method1` with [1, 2, 3] was not recorded"
  end

end
