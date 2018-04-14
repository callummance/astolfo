defmodule Managers.Thread.Command.Interpret do
  @moduledoc """
  Module containing functions for interpreting text commands submitted in
  discord messages.
  """
  require DiscordInterface.Server
  require Logger

  @command_prefix "!"

  @doc """
  Interprets the initial command and either carries it out or begins the
  data gathering process, returning a conversation_thread object with the
  updated callback.
  """
  def start_thread(message, conversation_thread) do
    command = select_command(message.content)
    Logger.info("Interpreting message #{message.content} as #{command}")
  end

  @doc """
  Takes the text content of a command message and returns an atom representing
  the requested command.
  """
  def select_command(command_text) do
    prefix = String.first(command_text)
    if (prefix == @command_prefix) do
      command = command_text
        |> String.split(" ")
        |> List.first()
        |> (&String.slice(&1, 1..-1)).()

      case command do
        #Admin commands
        "addmanaged"      -> :add_managed_role
        "addregistration" -> :add_registration_method
        "enforcebot"      -> :enforce_bot_registration
        "setadminrole"    -> :set_admin_role
        "setadminchannel" -> :set_admin_channel
        "resetserver"     -> :reset
        #User commands
        "register"        -> :register_user
        "get"             -> :get_details
        "help"            -> :show_help
        "plsrescue"       -> :summon_admin
        _                 -> :none
      end
    else
      :none
    end
  end

  @doc """
  Enables bot management for a given role name for a given server, creating
  it if needed, but only if the user_id given is the server owner or has
  the admin role.
  """
  def do_command(:add_managed_role, server_id, role_name, user_id) do
    #Check if the role really exists
    matching_roles = Enum.filter(DiscordInterface.Server.get_server_roles(server_id), fn(r) ->
          r.name == role_name
      ||  "##{r.name}" == role_name
    end)

    case matching_roles do
      #Matching role does not exist, so confirm with the user if a new one
      #should be created.
      [] -> []
      [r] -> r #Role exists \o/
      _   -> raise "wtf multiple roles matched for '#{role_name}' in server #{server_id}" #WTF mutiple roles matched?
    end
  end

  @doc """
  Returns true iff the given user is the owner of the given server
  """
  defp is_server_owner?(server_id, user_id) do
    user_id == DiscordInterface.Server.get_server_owner!(server_id)
  end

  @doc """
  Returns true iff the given user is a member of the admin role set for the
  given server or is the server owner
  """
  defp is_server_admin?(server_id, user_id) do
    case is_server_owner?(server_id, user_id) do
      true  -> true
      false ->
        roles = DiscordInterface.Server.get_member_roles!(server_id, user_id)
        server_meta = Db.Server.get_server_by_id(server_id)
        administrator_role = server_meta.administrator_role
        Enum.member?(roles, administrator_role)
    end
  end
end
