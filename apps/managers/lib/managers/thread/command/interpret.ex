defmodule Managers.Thread.Command.Interpret do
  @moduledoc """
  Module containing functions for interpreting text commands submitted in
  discord messages.
  """
  alias DiscordInterface.Server
  alias DiscordInterface.Message
  alias Managers.Thread.Command.AddManaged
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
    case command do
      :none ->
        {:stop}
      com ->
        do_command(command, message, conversation_thread)
    end
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
        "reqreginfo"      -> :add_required_registration_info
        "requserinfo"     -> :add_required_user_info
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
  def do_command(:add_managed_role, message, conversation_thread) do
    server_id = conversation_thread.server_id
    user_id = conversation_thread.user_id
    chan_id = conversation_thread.channel_id
    case Enum.fetch(message.content |> String.split(" "), 1) do
      {:ok, role_name} ->
        case is_server_admin?(server_id, user_id) do
          true -> #User is admin or server owner, so continue
            Logger.info("Add role command issued by #{user_id}, admin check succeeded.")
            #Check if the role really exists
            matching_roles = Enum.filter(DiscordInterface.Server.get_server_roles!(server_id), fn(r) ->
                  r["name"] == role_name
              ||  "##{r["name"]}" == role_name
            end)

            case matching_roles do
              #Matching role does not exist, so confirm with the user if a new one
              #should be created.
              [] ->
                Message.wait_then_send("I couldn't find a role with that name. Would you like me to create one?", chan_id)
                {:continue, (&AddManaged.confirm_new_role(&1, &2, role_name))}
              [r] ->
                ManServer.add_managed_role(server_id, r)
                Message.wait_then_send("All done!", chan_id)
                {:stop}
              _   ->
                raise "wtf multiple roles matched for '#{role_name}' in server #{server_id}" #WTF mutiple roles matched?
                {:stop}
            end
          false -> #User is not admin, so terminate
            Logger.warn("Add role command issued by #{user_id}, admin check failed.")
            DiscordInterface.Message.wait_then_send("米なさい、that command is only available to admins.", chan_id)
            {:stop}
        end
      :error ->
        DiscordInterface.Message.wait_then_send("Sorry, I need a name for the target role! Please use the syntax !addmanaged <role_name>.", chan_id)
        {:stop}
    end
  end

  @doc """
  Adds a field to the information that needs to be retrieved from a registration
  provider. Any information not available will require admin intervention.
  """
  def do_command(:add_reqired_registration_info, message, conversation_thread) do
    server_id = conversation_thread.server_id
    user_id = conversation_thread.user_id
    chan_id = conversation_thread.channel_id
    case is_server_admin?(server_id, user_id) do
      true ->
        case Enum.fetch(message.content |> String.split(" "), 1) do
          {:ok, role_name} ->
            case Enum.fetch(message.content |> String.split(" "), 2) do
              {:ok, required_info} -> {:stop}
                #2 arguments given
              :error -> {:stop}
                #1 argument given
            end
          :error -> {:stop}
            #0 arguments given
        end
      false ->
        Logger.warn("Add role command issued by #{user_id}, admin check failed.")
        DiscordInterface.Message.wait_then_send("米なさい、that command is only available to admins.", chan_id)
        {:stop}
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
    Logger.info("Now performing admin check for user #{user_id}")
    case is_server_owner?(server_id, user_id) do
      true  -> true
      false ->
        roles = DiscordInterface.Server.get_member_roles!(server_id, user_id)
        case Db.Server.get_server_by_id(server_id) do
          {exists, server_meta} ->
            administrator_role = server_meta.administrator_role
            Enum.member?(roles, administrator_role)
          {:none} ->
            Logger.warn("nonexistant server found...?")
            false
        end
    end
  end
end
