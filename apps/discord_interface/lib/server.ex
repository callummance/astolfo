defmodule DiscordInterface.Server do
  alias Nostrum.Api

  def get_server_details(id) do
    Api.get_guild(id)
  end

  def get_channel_details!(id) do
    {:ok, chan} = get_server_details(id)
    chan
  end

end
