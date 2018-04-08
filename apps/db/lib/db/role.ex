defmodule Db.Role do
  @enforce_keys [:role_id]
  defstruct [:role_id, :server_id, :auth_requirements, :implies_roles]

end
