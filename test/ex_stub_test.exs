use ExStub

defmodule ExStubTest do
  use ExUnit.Case

  test "can stub 1 method" do
    defstub MyStub1, for: OriginalModule do
      def process(%{cool: 2}), do: :new2
    end

    assert MyStub1.process(%{cool: 1}) == :old1
    assert MyStub1.process(%{cool: 2}) == :new2
    assert MyStub1.process(%{cool: 3}) == :old3
    assert MyStub1.method1 == :method1
  end

  test "can stub 2 methods" do
    defstub MyStub2, for: OriginalModule do
      def process(%{cool: 1}), do: :new1
      def process(%{cool: 2}), do: :new2
    end

    assert MyStub2.process(%{cool: 1}) == :new1
    assert MyStub2.process(%{cool: 2}) == :new2
    assert MyStub2.process(%{cool: 3}) == :old3
    assert MyStub2.method1 == :method1
  end

  test "can stub 3 methods" do
    defstub MyStub3, for: OriginalModule do
      def process(%{cool: 1}), do: :new1
      def method1, do: :new_method1
    end

    assert MyStub3.process(%{cool: 1}) == :new1
    assert MyStub3.process(%{cool: 2}) == :old2
    assert MyStub3.process(%{cool: 3}) == :old3
    assert MyStub3.method1 == :new_method1
  end

  test "stubs multi line functions" do
    defstub MyStub4, for: OriginalModule do
      def process(%{cool: 1}) do
        :something
        :new1
      end
      def method1, do: :new_method1
    end

    assert MyStub4.process(%{cool: 1}) == :new1
    assert MyStub4.process(%{cool: 2}) == :old2
    assert MyStub4.process(%{cool: 3}) == :old3
    assert MyStub4.method1 == :new_method1
  end

  test "stubs out of order functions" do
    defstub MyStub5, for: OriginalModule do
      def process(%{cool: 1}), do: :new1
      def method1, do: :new_method1
      def process(%{cool: 2}), do: :new2
    end

    assert MyStub5.process(%{cool: 1}) == :new1
    assert MyStub5.process(%{cool: 2}) == :new2
    assert MyStub5.process(%{cool: 3}) == :old3
    assert MyStub5.method1 == :new_method1
  end

  test "works with empty stubs" do
    defstub MyStub6, for: OriginalModule do
    end

    assert MyStub6.process(%{cool: 1}) == :old1
    assert MyStub6.process(%{cool: 2}) == :old2
    assert MyStub6.process(%{cool: 3}) == :old3
    assert MyStub6.method1 == :method1
  end

  test "it does not stub non exisiting functions" do
    assert_raise RuntimeError, fn ->
      quote do
        defstub MyStub7, for: OriginalModule do
          def anything(a), do: :new1
        end
      end
      |> Code.eval_quoted
    end
  end
end
