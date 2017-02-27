use ExStub

defstub MyEndToEndStub, for: OriginalModule do
  def process(%{cool: 2}), do: :new2
end

defmodule MyEndToEndStubTest do
  use ExUnit.Case

  test "it works end to end" do
    MyEndToEndStub.process(%{cool: 1})
    assert_called MyEndToEndStub.process(%{cool: 1})
  end
end
