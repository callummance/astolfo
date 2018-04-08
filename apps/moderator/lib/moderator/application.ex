defmodule Moderator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Moderator.Worker.start_link(arg)
      # {Moderator.Worker, arg},
      worker(Moderator.ModeratorServer, [[name: :moderator_server]])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Moderator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
