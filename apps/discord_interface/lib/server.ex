defmodule DiscordInterface.Server do
  alias Nostrum.Api

  def get_server_details(id) do
    Api.get_guild(id)
  end

  def get_server_details!(id) do
    {:ok, chan} = get_server_details(id)
    chan
  end

  def get_server_roles(id) do
    Api.get_guild_roles(id)
  end

  def get_server_roles!(id) do
    {:ok, roles} = get_server_roles(id)
  end

  def get_server_owner!(id) do
    {:ok, details} = get_server_details(id)
    details.owner_id
  end

  def get_member_roles!(sid, uid) do
    {:ok, member} = Api.get_member(sid, uid)
    member.roles
  end

end
