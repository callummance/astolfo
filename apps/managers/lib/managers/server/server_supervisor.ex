defmodule Managers.Server.Supervisor do
  @moduledoc """
  Supervisor in charge of creating dynamic `Managers.Server.ManServer` actors,
  with one existing for each server id.
  """
  use Supervisor
  require Logger

  @registry_name :server_manager_registry

@doc """
Starts the supervisor
"""
  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

@doc """
Locates the thread for a server manager worker if it exists, or spawns a new
one and inserts it into the registry if it does not
"""
  def find_or_create(server_id) do
    if server_manager_exists?(server_id) do
      {:ok, server_id}
    else
      Logger.info("Starting thread for server #{server_id}")
      server_id |> create_server_manager
    end
  end

@doc """
Returns true iff a manager for the server with id `server_id` already exists.
"""
  def server_manager_exists?(server_id) do
    case Registry.lookup(@registry_name, server_id) do
      []  -> false
      _   -> true
    end
  end

@doc """
Creates a new manager process for the server with id server_id.
"""
  def create_server_manager(server_id) do
    case Supervisor.start_child(__MODULE__, [server_id]) do
      {:ok, pid}                            -> {:ok, server_id}
      {:error, {:already_started, _pid}}    -> {:error, :process_already_exists}
      other                                 -> {:error, other}
    end
  end

@doc false
  def init (_) do
    #list all child process to be supervised
    children = [
      %{id:       Managers.Server.ManServer,
        start:    {Managers.Server.ManServer, :start_link, []},
        restart:  :temporary}
    ]

    Supervisor.init(children, strategy: :simple_one_for_one)
  end
end
