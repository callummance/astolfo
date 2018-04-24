defmodule Managers.Thread.Command.AddManaged do

  alias DiscordInterface.Server
  alias DiscordInterface.Message
  alias Managers.Server.ManServer

  def confirm_new_role(message, conversation_thread, role_name) do
    cond do
      String.contains?(String.downcase(message.content), "yes") ->
        newrole = Server.add_role!(conversation_thread.server_id, role_name)
        ManServer.add_managed_role(conversation_thread.server_id, newrole)
        Message.wait_then_send("All done!", conversation_thread.channel_id)
        {:stop}
      String.contains?(String.downcase(message.content), "no") ->
        {:stop}
      true ->
        Message.wait_then_send("Sorry, could you answer Yes/No please?", conversation_thread.channel_id)
        {:repeat}
    end
  end
end
