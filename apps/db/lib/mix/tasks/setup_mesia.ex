defmodule Mix.Tasks.SetupMnesia do
  use Mix.Task

  def run(_args) do
    nodes = [Node.self | Node.list]
    IO.puts("Initializing mnesia DB on #{Enum.count(nodes)} nodes.")
    :mnesia.create_schema(nodes)
    :mnesia.start()

    :mnesia.create_table(User,
                         [attributes: [:user_id, :notes],
                          disc_copies: nodes])

    :mnesia.create_table(ServerMember,
                          [attributes: [:server_id, :user_id, :roles, :links],
                           type: :bag,
                           disc_copies: nodes,
                           index: [:user_id, :server_id]])

    :mnesia.create_table(Server,
                          [attributes: [:server_id, :administrator_role, :member_role, :bot_channel, :owner_id],
                           disc_copies: nodes])

    :mnesia.create_table(Role,
                          [attributes: [:role_id, :server_id, :auth_requirements, :implies_roles],
                           disc_copies: nodes])

    :mnesia.create_table(Channel,
                          [attributes: [:channel_id, :server_id, :required_role, :channel_type],
                           disc_copies: nodes])
  end
end
