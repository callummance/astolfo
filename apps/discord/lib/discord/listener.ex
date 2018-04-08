defmodule Discord.Listener do

  alias Discord.Util
  alias Discord.MessageCategorise

  require Logger
  use Nostrum.TaskedConsumer

  @bot_permissions [:administrator]

  def start_link do
    TaskedConsumer.start_link(__MODULE__)
  end

  def handle_event({:READY, {_map}, _ws_state}) do
    bot_id = Application.get_env(:discord, :bot_id, -1)
    Logger.info "Discord client connected."
    IO.puts("Add bot to server using the following link: #{Util.get_bot_auth_url(bot_id, @bot_permissions)}")
  end

  def handle_event({:MESSAGE_CREATE, {msg}, _ws_state}) do
    MessageCategorise.process_message(msg)
  end

  def handle_event(_) do
    :noop
  end

end

