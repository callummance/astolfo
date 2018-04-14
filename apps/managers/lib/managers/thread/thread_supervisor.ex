defmodule Managers.Thread.Supervisor do
  @moduledoc """
  Supervisor in charge of creating dynamic `Managers.Thread.ThreadManager`
  actors.
  """
  use Supervisor
  require Logger

  @registry_name :conversation_thread_registry

@doc """
Starts the supervisor
"""
  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

@doc """
Locates the thread for a thread manager worker if it exists, or spawns a new
one and inserts it into the registry if it does not
"""
  def find_or_create(server_id, channel_id, user_id) do
    if thread_manager_exists?(server_id, channel_id, user_id) do
      {:ok, {server_id, channel_id, user_id}}
    else
      Logger.info("Starting thread for conversation {#{server_id}, #{channel_id}, #{user_id}}")
      create_thread_manager(server_id, channel_id, user_id)
    end
  end

@doc """
Returns true iff a manager for the referenced conversation thread exists.
"""
  def thread_manager_exists?(server_id, channel_id, user_id) do
    case Registry.lookup(@registry_name, {server_id, channel_id, user_id}) do
      []  -> false
      _   -> true
    end
  end

@doc """
Creates a new manager process for the given conversation.
"""
  def create_thread_manager(server_id, channel_id, user_id) do
    id = {server_id, channel_id, user_id}
    case Supervisor.start_child(__MODULE__, [id]) do
      {:ok, pid}                            -> {:ok, id}
      {:error, {:already_started, _pid}}    -> {:error, :process_already_exists}
      other                                 -> {:error, other}
    end
  end

@doc false
  def init (_) do
    #list all child process to be supervised
    children = [
      %{id:       Managers.Thread.ThreadManager,
        start:    {Managers.Thread.ThreadManager, :start_link, []},
        restart:  :temporary}
    ]

    Supervisor.init(children, strategy: :simple_one_for_one)
  end
end
