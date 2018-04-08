defmodule Discord do
  use Application
  @moduledoc """
  Modular registration bot for Discord.
  """

  alias Discord.Listener

  def start(_, _) do
    import Supervisor.Spec

    children = for i <- 1..System.schedulers_online, do: worker(Listener, [], id: i)
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
