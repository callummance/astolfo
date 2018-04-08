defmodule Discord.Util do
  use Bitwise

  @bot_base_auth_url "https://discordapp.com/api/oauth2/authorize"

  def full_permissions_list do
    [:create_instant_invite,
     :kick_members,
     :ban_members,
     :administrator,
     :manage_channels,
     :manage_guild,
     :add_reactions,
     :view_audit_log,
     :view_channel,
     :send_messages,
     :send_tts_messages,
     :manage_messages,
     :embed_links,
     :attach_files,
     :read_message_history,
     :mention_everyone,
     :use_external_emojis,
     :connect,
     :speak,
     :mute_members,
     :defaen_members,
     :move_members,
     :use_vad,
     :change_nickname,
     :manage_nicknames,
     :manage_roles,
     :manage_webhooks,
     :manage_emojis]
     |> Enum.with_index
     |> Enum.map(fn({n, id}) -> {n, 1 <<< id} end)
     |> Map.new

  end

  def calculate_permissions_bitstring(perms) do
    Enum.map(perms, fn(p) -> full_permissions_list()[p] end)
    |> Enum.reduce(0, fn(x, acc) -> x ||| acc end)
  end

  def get_bot_auth_url(id, permissions) do
    "#{@bot_base_auth_url}?client_id=#{id}&scope=bot&permissions=#{calculate_permissions_bitstring(permissions)}"
  end

end

