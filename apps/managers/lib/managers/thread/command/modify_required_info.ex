defmodule Managers.Thread.Command.ModifyRequiredInfo do

  alias DiscordInterface.Message

  def get_role_and_field(sid, uid, cid) do
    Message.wait_then_send("Which role do you want to modify?", cid)
    {:continue, &check_role/2}
  end

  def check_role(message, conversation_thread) do
    cid = conversation_thread.channel_id
    role_name = message.content
    matching_roles = Enum.filter(DiscordInterface.Server.get_server_roles!(conversation_thread.server_id), fn(r) ->
          r["name"] == role_name
      ||  "##{r["name"]}" == role_name
    end)
    case matching_roles do
      [] -> #No matching roles, try again
        Message.wait_then_send("I couldn't find any roles with that name", cid)
        {:stop}
      [r] -> #One matching role found
        case Db.Role.get_role_by_id(r["id"]) do
          {:none} ->
            Message.wait_then_send("I'm not currently managing that role. Please use the `addmanaged` command if you want me to.", cid)
            {:stop}
          {:exists, r_local} ->
            Message.wait_then_send("Gottit \o/", cid)
        end
    end
  end

  def get_field(sid, uid, cid, rid) do
    Message.wait_then_send("What do you want me to know about everyone?", cid)
    available_auth_methods = []
  end
end
