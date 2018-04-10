defmodule Discord.MessageCategorise do
  require Logger

  alias Moderator.ModeratorServer

  @default_command_prefix "!"

  defp is_command?(msg) do
    com_prefix = Application.get_env(:discord, :com_prefix, @default_command_prefix)
    String.starts_with?(msg.content, com_prefix)
  end

  defp should_check?(msg) do
    bot_id = Application.get_env(:discord, :bot_id, -1)
    msg.author.id != bot_id
  end

  def process_message(msg) do
    if should_check?(msg) do
      case ModeratorServer.check_message(msg) do
        {:ok} ->
          if is_command?(msg) do
            Managers.handle_message(msg)
          end
        {:rejected, reason} ->
          Logger.info("Moderator rejected message #{msg.content} due to the following reason: #{reason}.")
      end
    end
  end

  def check_msg(msg) do
    IO.puts(msg.content)
  end
end
