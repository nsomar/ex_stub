# ExStub

`ExStub` provides an easy way to stub a module to facilitate writing clean, isolated unit tests.

## Installation

Add `ex_stub` to your deps in `mix.exs`

```elixir
def deps do
  [{:ex_stub, "~> 0.1.0"}]
end
```

## Usage

If you have a module in your original application like:

```elixir
defmodule OriginalModule do
  def process(param), do: :original_process
  def another_method, do: :original_method
end
```

You can quickly create a stub copy of this module using `defstub`

```elixir
use ExStub

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

MyStub.process(20) # returns :original_process

MyStub.another_method # returns :original_method
```

Notice that Since we did not stub `another_method`, calling it on `MyStub` returns the original implementation.
Also when calling `MyStub.process(20)` the original implementation is called since it failed pattern matching with our stub version of the method.

----

As a safety procedure, if you try to stub a method that is not found in the original module. ExStub will throw a compilation error telling you about the unexpected stubbed method.

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

