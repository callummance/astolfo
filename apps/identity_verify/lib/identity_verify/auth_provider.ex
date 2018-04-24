defmodule IdentityVerify.AuthProvider do
  @callback provides_fields(conf :: any) :: list(atom)
  @callback begin_registration(conf :: any, callback :: fun(data :: any)) :: String.t
end
