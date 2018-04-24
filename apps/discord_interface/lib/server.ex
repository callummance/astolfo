defmodule DiscordInterface.Server do
  alias Nostrum.Api
  alias Db.Server
  require Logger

  def get_server_details(id) do
    Logger.info("Now retrieving details on server #{id}.")
    Api.get_guild(id)
  end

  def get_server_details!(id) do
    {:ok, chan} = get_server_details(id)
    chan
  end

  def get_server_roles(id) do
    Logger.info("Now retrieving roles for server #{id}.")
    Api.get_guild_roles(id)
  end

  def get_server_roles!(id) do
    {:ok, roles} = get_server_roles(id)
    roles
  end

  def get_server_owner!(id) do
    {:ok, details} = get_server_details(id)
    Logger.debug("Got server owner: #{details.owner_id}")
    String.to_integer(details.owner_id)
  end

  def get_member_roles!(sid, uid) do
    {:ok, member} = Api.get_member(sid, uid)
    member["roles"]
  end

  def add_role!(sid, name) do
    Api.create_guild_role(sid, %{name: name})
    newroles = get_server_roles!(sid)
    Enum.filter(newroles, fn(r) -> r["name"] == name end) |> List.first
  end
end
