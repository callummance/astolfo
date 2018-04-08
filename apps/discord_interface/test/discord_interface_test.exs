defmodule DiscordInterfaceTest do
  use ExUnit.Case
  doctest DiscordInterface

  test "greets the world" do
    assert DiscordInterface.hello() == :world
  end
end
