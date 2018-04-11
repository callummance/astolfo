defmodule Managers do

  require Logger

  def handle_message(msg) do
    Managers.Channel.Supervisor.handle_message(msg)
  end
end
