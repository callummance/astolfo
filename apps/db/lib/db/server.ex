defmodule Db.Server do
  @enforce_keys [:server_id]
  defstruct [:server_id, :administrator_role, :member_role, :bot_channel, :owner_id]

  alias Db.Channel
  alias Db.Role

  @doc """
  Retrieves server details for a given server id from the database if they
  are present
  """
  def get_server_by_id(sid) do
    case :mnesia.transaction(fn -> :mnesia.read({Server, sid}) end) do
      {:atomic, [{Server, sid, administrator_role, member_role, bot_channel, owner_id}]} ->
        {:exists, %Db.Server{server_id: sid, administrator_role: administrator_role, member_role: member_role, bot_channel: bot_channel, owner_id: owner_id}}
      {:atomic, _} ->
        {:none}
    end
  end

  def write_server(server) do
    :mnesia.transaction(
      fn ->
        :mnesia.write({Server, server.server_id, server.administrator_role, server.member_role, server.bot_channel, server.owner_id})
      end
    )
  end
end
