defmodule ModeratorTest do
  use ExUnit.Case
  doctest Moderator

  test "greets the world" do
    assert Moderator.hello() == :world
  end
end
