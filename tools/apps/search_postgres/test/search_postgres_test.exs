defmodule SearchPostgresTest do
  use ExUnit.Case
  doctest SearchPostgres

  test "greets the world" do
    assert SearchPostgres.hello() == :world
  end
end
