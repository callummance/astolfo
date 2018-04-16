defmodule DiscordInterface.Message do
  alias Nostrum.Api

  @default_delay 1000

  def reply(message, text) do
    Api.create_message(message.channel_id, text, false)
  end

  def send(message, cid) do
    Api.create_message(cid, message, false)
  end

  def wait_then_send(message, cid, delay) do
    Api.start_typing!(cid)
    :timer.sleep(delay)
    Api.create_message!(cid, message, false)
  end

  def wait_then_send(message, cid) do
    wait_then_send(message, cid, @default_delay)
  end


end
