defmodule Db.User do
  @enforce_keys [:uid]
  defstruct [:uid, :notes]

  alias Db.User
  alias Db.Member

  def get_user(uid) do
    {:atomic, [{Person, uid, notes}]} = :mnesia.transaction(
      fn ->
        :mnesia.read({User, uid})
      end
    )

    %User{uid: uid, notes: notes}
  end

  def get_server_membership(user) do
    uid = user.uid
    {:atomic, members} = :mnesia.transaction(
      fn -> 
        :mnesia.index_read(ServerMember, uid, :user_id)
      end
    )

    Enum.map(members, 
             fn({Member, sid, uid, roles, links}) ->
               %Member{server_id: sid, user_id: uid, roles: roles, links: links}
             end
    )

  end


end
