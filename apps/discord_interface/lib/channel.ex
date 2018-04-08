defmodule DiscordInterface.Channel do
  alias Nostrum.Api

  def get_channel_details(id) do
    Api.get_channel(id)
  end

  def get_channel_details!(id) do
    {:ok, chan} = get_channel_details(id)
    chan
  end

end
