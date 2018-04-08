defmodule Db.Member do
  @enforce_keys [:server_id, :user_id]
  defstruct [:server_id, :user_id, :roles, :links]

  alias Db.User
  alias Db.Member

  def get_member(uid, sid) do
    {:atomic, [{Member, uid, notes}]} = :mnesia.transaction(
      fn ->
        :mnesia.match_object({Member, sid, uid, :_, :_})
      end
    )

    %Member{server_id: sid, user_id: uid}
  end
end
