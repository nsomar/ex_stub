# ExStub
[![Build Status](https://travis-ci.org/oarrabi/ex_stub.svg?branch=master)](https://travis-ci.org/oarrabi/ex_stub)
[![Hex.pm](https://img.shields.io/hexpm/v/ex_stub.svg)](https://hex.pm/packages/ex_stub)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](http://hexdocs.pm/ex_stub/)
[![Coverage Status](https://coveralls.io/repos/github/oarrabi/ex_stub/badge.svg?branch=master)](https://coveralls.io/github/oarrabi/ex_stub?branch=master)
[![Inline docs](http://inch-ci.org/github/oarrabi/ex_stub.svg?branch=master)](http://inch-ci.org/github/oarrabi/ex_stub)

`ExStub` provides an easy way to stub a module and record the function calls on it.

## Installation

Add `ex_stub` to your deps in `mix.exs` as a development dependency.

```elixir
def deps do
  [{:ex_stub, "~> 0.1.0", only: :test}]
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

## Recording method calls
All the functions called on the `defstub` created module will be recorded.

To get all the functions calls on `YourModule` module
```elixir
ExStub.Recorder.calls(YourModule)
```

To get all the `:the_method` function calls on `YourModule` 
```elixr
ExStub.Recorder.calls(YourModule, :the_method)
```

Alternativey, you can use `assert_called` in your unit tests:

```elixir
MyStub.process(1)

# Passes since we called the function with [1]
assert_called MyStub, process, with: [1]

# Fails since the parameters dont match
assert_called MyStub, process, with: [1, 2]

# Fails since we did not call `another_method`
assert_called MyStub, another_method, with: []
```
