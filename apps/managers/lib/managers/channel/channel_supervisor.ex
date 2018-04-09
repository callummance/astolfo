defmodule Managers.Channel.Supervisor do
  @moduledoc """
  Supervisor in charge of creating dynamic `Managers.Server.ManServer` actors,
  with one existing for each server id.
  """
  use Supervisor
  require Logger

  @registry_name :channel_manager_registry

  @doc """
  Starts the supervisor
  """
  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Locates the thread for a channel manager worker if it exists, or spawns a new
  one and inserts it into the registry if it does not
  """
    def find_or_create(channel_id) do
      if channel_manager_exists?(channel_id) do
        {:ok, channel_id}
      else
        channel_id |> create_channel_manager
      end
    end

  @doc """
  Returns true iff a manager for the channel with id `channel_id` already exists.
  """
    def channel_manager_exists?(channel_id) do
      case Registry.lookup(@registry_name, channel_id) do
        []  -> false
        _   -> true
      end
    end

  @doc """
  Creates a new manager process for the channel with id `channel_id`.
  """
    def create_channel_manager(channel_id) do
      case Supervisor.start_child(__MODULE__, [channel_id]) do
        {:ok, pid}                            -> {:ok, channel_id}
        {:error, {:already_started, _pid}}    -> {:error, :process_already_exists}
        other                                 -> {:error, other}
      end
    end

  @doc false
  def init (_) do
    #list all child process to be supervised
    children = [
      %{id:       Managers.Channel.ManChannel,
        start:    {Managers.Channel.ManChannel, :start_link, []},
        restart:  :temporary}
    ]

    Supervisor.init(children, strategy: :simple_one_for_one)
  end
end
