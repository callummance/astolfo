defmodule ManagersTest do
  use ExUnit.Case
  doctest Managers

  test "greets the world" do
    assert Managers.hello() == :world
  end
end
