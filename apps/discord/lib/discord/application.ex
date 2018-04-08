defmodule Discord.Application do
  use Application
  @moduledoc """
  Modular registration bot for Discord.
  """

  def start(_, _) do
    import Supervisor.Spec

    #{:ok, table} = :dets.open_file(:astolfo_storage, [type: :set])

    children = for i <- 1..System.schedulers_online, do: worker(Discord.Listener, [], id: i)
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
