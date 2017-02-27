use ExStub

defmodule ExStubRecordingTest do
  use ExUnit.Case

  test "can record non stubbed method calls" do
    defstub MyStubRecording1, for: OriginalModule do
      def process(%{cool: 2}), do: :new2
    end

    MyStubRecording1.process(%{cool: 1})
    MyStubRecording1.process(%{cool: 1})
    MyStubRecording1.process(%{cool: 1})
    MyStubRecording1.process(%{cool: 1})

    assert MyStubRecording1.__calls__ ==
    [process: [%{cool: 1}], process: [%{cool: 1}], process: [%{cool: 1}], process: [%{cool: 1}]]
  end

  test "can record method calls" do
    defstub MyStubRecording2, for: OriginalModule do
      def process(%{cool: 2}) do
        :new2
      end
    end

    MyStubRecording2.process(%{cool: 2})
    MyStubRecording2.process(%{cool: 2})
    MyStubRecording2.process(%{cool: 2})
    MyStubRecording2.process(%{cool: 2})
    assert ExStub.Recorder.calls(MyStubRecording2) ==
    [process: [%{cool: 2}], process: [%{cool: 2}], process: [%{cool: 2}], process: [%{cool: 2}]]
  end

  test "can record method calls for multiline method" do
    defstub MyStubRecording3, for: OriginalModule do
      def process(%{cool: 2}) do
        :new2
      end

      def process(%{cool: :hello}) do
        x = 1
        y = 2
        x + y
      end
    end

    assert MyStubRecording3.process(%{cool: 2}) == :new2
    assert MyStubRecording3.process(%{cool: :hello}) == 3
    assert MyStubRecording3.process(%{cool: :hello}) == 3
    assert MyStubRecording3.process(%{cool: 2}) == :new2
    assert ExStub.Recorder.calls(MyStubRecording3) ==
    [process: [%{cool: 2}], process: [%{cool: :hello}], process: [%{cool: :hello}], process: [%{cool: 2}]]
  end

  test "can record method calls with no params" do
    defstub MyStubRecording4, for: OriginalModule do
      def method1 do
        :new_method
      end
    end

    assert MyStubRecording4.method1 == :new_method
    assert MyStubRecording4.process(%{cool: 1}) == :old1
    assert ExStub.Recorder.calls(MyStubRecording4) ==
    [method1: [], process: [%{cool: 1}]]
  end

  test "assert called works too" do
    defstub MyStubRecording5, for: OriginalModule do
      def method1 do
        :new_method
      end
    end

    assert MyStubRecording5.method1 == :new_method
    assert MyStubRecording5.process(%{cool: 1}) == :old1

    assert_called MyStubRecording5, method1, with: []
    assert_called MyStubRecording5, process, with: [%{cool: 1}]
  end

  test "assert called with constant params" do
    defstub MyStubRecording6, for: OriginalModule do
      def process(20), do: :new_method
    end

    assert MyStubRecording6.method1 == :method1
    assert MyStubRecording6.process(%{cool: 1}) == :old1

    assert_called MyStubRecording6, method1, with: []
    assert_called MyStubRecording6, process, with: [%{cool: 1}]
  end
end
