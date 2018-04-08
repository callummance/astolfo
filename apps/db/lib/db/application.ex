defmodule Db.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    :mnesia.start()
    children = [
      # Starts a worker by calling: Db.Worker.start_link(arg)
      # {Db.Worker, arg},
    ]

    opts = [strategy: :one_for_one, name: Db.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
