defmodule Db.Channel do
  @enforce_keys [:channel_id]
  defstruct [:channel_id, :server_id, :required_role, :channel_type]

  alias Db.Server
  alias Db.Role

  def get_channel_by_id(cid) do
    {:atomic, channel_data} = :mnesia.transaction(
      fn ->
        :mnesia.read({Channel, cid})
      end
    )

    case channel_data do
      [] ->
        {:none}
      [{Channel, cid, sid, required_role, channel_type}] ->
        {:exists, %Db.Channel{channel_id: cid, server_id: sid, required_role: required_role, channel_type: channel_type}}
    end
  end

  def write_channel(channel) do
    :mnesia.transaction(
      fn ->
        :mnesia.write({Channel, channel.channel_id, channel.server_id, channel.required_role, channel.channel_type})
      end
    )
  end

  def get_server(channel) do
    sid = channel.server_id
    res = :mnesia.transaction(
      fn -> 
        :mnesia.index_read(Server, sid, :server_id)
      end
    )
    case res do
      {:atomic, [{Server, sid, administrator_role, member_role, bot_channel}]} -> 
        {:ok, %Server{server_id: sid, administrator_role: administrator_role, member_role: member_role, bot_channel: bot_channel}}
      {:aborted, details} ->
        {:none, details}
    end
  end
end
