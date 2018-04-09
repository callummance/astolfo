defmodule Managers.Channel.Channel do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      {Registry, keys: :unique, name: :channel_manager_registry},
      {Managers.Channel.Supervisor, []}
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end
