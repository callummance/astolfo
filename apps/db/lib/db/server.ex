defmodule Db.Server do
  @enforce_keys [:server_id]
  defstruct [:server_id, :administrator_role, :member_role, :bot_channel, :owner_id]

  alias Db.Channel
  alias Db.Role

  def get_server_by_id(sid) do
    {:atomic, [{Server, sid, administrator_role, member_role, bot_channel, owner_id}]} = :mnesia.transaction(
      fn ->
        :mnesia.read({Server, sid})
      end
    )

    %Db.Server{server_id: sid, administrator_role: administrator_role, member_role: member_role, bot_channel: bot_channel, owner_id: owner_id}
  end

  def write_server(server) do
    :mnesia.transaction(
      fn ->
        :mnesia.write({Server, server.server_id, server.administrator_role, server.member_role, server.bot_channel, server.owner_id})
      end
    )
  end
end
