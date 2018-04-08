defmodule Managers.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: :manager_supervisor)
  end

  def start_channel_manager(id) do
    Supervisor.start_child(:manager_supervisor, [id])
  end

  def init (_) do
    # List all child processes to be supervised
    children = [
      supervisor(Registry, [:unique, :channel_manager_registry]),
      supervisor(Registry, [:unique, :server_manager_registry])
      #worker(Managers.ManChannel, [])
    ]
    #opts = [strategy: :one_for_one, name: Managers.Supervisor]
    supervise(children, strategy: :simple_one_for_one)
  end
end
