defmodule Mix.Tasks.SetupMnesia do
  use Mix.Task

  def run(_args) do
    Mix.shell.info("test")
    :mnesia.start()
    :mnesia.create_schema([node()])

    :mnesia.create_table(User,          [attributes: [:user_id, :notes]])

    :mnesia.create_table(ServerMember,  [attributes: [:server_id, :user_id, :roles, :links], type: :bag])
    :mnesia.add_table_index(ServerMember, :user_id)
    :mnesia.add_table_index(ServerMember, :server_id)

    :mnesia.create_table(Server,        [attributes: [:server_id, :administrator_role, :member_role, :bot_channel, :owner_id]])

    :mnesia.create_table(Role,          [attributes: [:role_id, :server_id, :auth_requirements, :implies_roles]])

    :mnesia.create_table(Channel,       [attributes: [:channel_id, :server_id, :required_role, :channel_type]])
  end
end
