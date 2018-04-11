defmodule Managers.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    #Start registry and child supervisors
    children = [
      {Managers.Server.Server, []},
      {Managers.Channel.Channel, []}
    ]

    options = [strategy: :one_for_one]
    Supervisor.start_link(children, options)
  end
end
