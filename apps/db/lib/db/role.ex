defmodule Db.Role do

  require Logger

  @enforce_keys [:role_id]
  defstruct [:role_id, :server_id, :auth_methods, :required_reg_info, :required_user_info]

  def write_role(role) do
    :mnesia.transaction(
      fn ->
        :mnesia.write({Role, role.role_id, role.server_id, role.auth_methods, role.required_reg_info, role.required_user_info})
      end
    )
  end

  def get_role_by_id(rid) do
    {:atomic, role_data} = :mnesia.transaction(
      fn ->
        :mnesia.read({Role, rid})
      end
    )

    Logger.debug("Got role data from local DB: #{inspect(role_data)}")
    case role_data do
      [] ->
        {:none}
      [{Role, rid, sid, auth, reg_info, usr_info}] ->
        {:exists, %Db.Role{role_id: rid, server_id: sid, auth_methods: auth, required_reg_info: reg_info, required_user_info: usr_info}}
    end
  end
end
