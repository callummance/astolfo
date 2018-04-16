defmodule Db.Role do
  @enforce_keys [:role_id]
  defstruct [:role_id, :server_id, :auth_methods, :required_reg_info, :required_user_info]

  def write_role(role) do
    :mnesia.transaction(
      fn ->
        :mnesia.write({Role, role.role_id, role.server_id, role.auth_methods, role.required_reg_info, role.required_user_info})
      end
    )
  end
end
