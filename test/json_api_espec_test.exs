defmodule JsonApiEspecTest do
  use ExUnit.Case
  doctest JsonApiEspec

  test "greets the world" do
    assert JsonApiEspec.hello() == :world
  end
end
