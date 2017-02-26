defmodule UtilsTest do
  use ExUnit.Case

  test "It can returns the functions passed to the defstub" do
    functions =
    {:__block__, [],
     [{:def, [],
       [{:process, [], [{:%{}, [], [cool: 1]}]}, [do: :new1]]},
      {:def, [], [{:method1, [], nil}, [do: :new_method1]]},
      {:def, [],
       [{:process, [], [{:%{}, [], [cool: 2]}]}, [do: :new2]]}]}

    assert ExStub.Utils.functions_passed(functions) == [
      {:def, [], [{:process, [], [{:%{}, [], [cool: 1]}]}, [do: :new1]]},
      {:def, [], [{:method1, [], nil}, [do: :new_method1]]},
      {:def, [], [{:process, [], [{:%{}, [], [cool: 2]}]}, [do: :new2]]}
    ]
  end

  test "it returns the function name and the params" do
    defs = [
      {:def, [], [{:process, [], [{:%{}, [], [cool: 1]}]}, [do: :new1]]},
      {:def, [], [{:method1, [], nil}, [do: :new_method1]]},
      {:def, [], [{:process, [], [{:%{}, [], [cool: 2]}]}, [do: :new2]]},
    ]

     assert ExStub.Utils.functions_and_params(defs) == [
      %DefInfo{catches_all: false, name: :process, arity: 1, params: [{:%{}, [], [cool: 1]}]},
      %DefInfo{catches_all: true, name: :method1, arity: 0, params: nil},
      %DefInfo{catches_all: false, name: :process, arity: 1, params: [{:%{}, [], [cool: 2]}]}
    ]
  end

  test "it knows if the function catches all with nil params" do
    assert DefInfo.catches_all?(nil) == true
  end

  test "it knows if the function catches all with param" do
    assert DefInfo.catches_all?([{:a, [line: 59], nil}]) == true

    assert DefInfo.catches_all?([{:%{}, [], [cool: 1]}]) == false

    assert DefInfo.catches_all?([{:a, [line: 59], nil}, {:%{}, [], [cool: 1]}]) == false

    assert DefInfo.catches_all?([{:a, [line: 59], nil}, {:b, [line: 59], nil}]) == true
  end

  # describe "catch_all_functions" do
    test "it calculates the functions to generate with 0 catch alls" do
      module_functions = [process: 1, method: 0]
      stub_functions = [
        %DefInfo{catches_all: false, name: :process, arity: 1},
        %DefInfo{catches_all: false, name: :method, arity: 0},
        %DefInfo{catches_all: false, name: :process, arity: 1}
      ]
      assert ExStub.Utils.catch_all_functions(module_functions, stub_functions) ==
      [process: 1, method: 0]
    end

    test "it calculates the functions to generate with 1 catch alls" do
      module_functions = [process: 1, method: 0]
      stub_functions = [
        %DefInfo{catches_all: false, name: :process, arity: 1},
        %DefInfo{catches_all: true, name: :method, arity: 0},
        %DefInfo{catches_all: false, name: :process, arity: 1}
      ]
      assert ExStub.Utils.catch_all_functions(module_functions, stub_functions) ==
      [process: 1]
    end

    test "it calculates the functions to generate with 2 catch alls" do
      module_functions = [process: 1, method: 0]
      stub_functions = [
        %DefInfo{catches_all: true, name: :process, arity: 1},
        %DefInfo{catches_all: true, name: :method, arity: 0},
        %DefInfo{catches_all: false, name: :process, arity: 1}
      ]
      assert ExStub.Utils.catch_all_functions(module_functions, stub_functions) ==
      []
    end
  # end

  # describe "non_exisiting_functions" do
    test "it calculates the non existing functions to generate with 0 catch alls" do
      module_functions = [process: 1, method: 0]
      stub_functions = [
        %DefInfo{catches_all: false, name: :process, arity: 1},
        %DefInfo{catches_all: false, name: :method, arity: 0},
        %DefInfo{catches_all: false, name: :process, arity: 1}
      ]
      assert ExStub.Utils.non_exisiting_functions(module_functions, stub_functions) ==
      []
    end

    test "it calculates the non existing functions to generate with 1 catch alls" do
      module_functions = [process: 1, method: 0, pass: 1]
      stub_functions = [
        %DefInfo{catches_all: false, name: :process, arity: 1},
        %DefInfo{catches_all: true, name: :method, arity: 0},
        %DefInfo{catches_all: false, name: :process, arity: 1}
      ]
      assert ExStub.Utils.non_exisiting_functions(module_functions, stub_functions) ==
      [pass: 1]
    end

    test "it calculates the non existing functions to generate with 2 catch alls" do
      module_functions = [process: 1, method: 0]
      stub_functions = [
        %DefInfo{catches_all: true, name: :process, arity: 1},
        %DefInfo{catches_all: true, name: :method, arity: 0},
        %DefInfo{catches_all: false, name: :process, arity: 1}
      ]
      assert ExStub.Utils.non_exisiting_functions(module_functions, stub_functions) ==
      []
    end
  # end
end
