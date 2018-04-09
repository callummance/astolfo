defmodule Managers.Server.ManServer do
  use GenServer

  require Logger

  @registry_name :server_manager_registry
  @process_lifetime_ms 86_400_000 #24 hours

  #Struct holding the state of this server manager
  defstruct server_id: 0,
            server_name: "",
            administrator_role: 0,
            member_role: 0,
            bot_channel: 0,
            owner_id: 0

  #API
  def start_link(sid) do
    GenServer.start_link(__MODULE__, [sid], name: via_tuple(sid))
  end

  def process_message(sid, message) do
    GenServer.cast(via_tuple(sid), {:process_message, message})
  end

  defp via_tuple(server_id) do
    {:via, Registry, {@registry_name, server_id}}
  end




  #SERVER
  def init([sid]) do
    GenServer.cast(self(), :get_server_details)
    {:ok, %{:sid => sid}}
  end

  def handle_cast(:get_server_details, state) do
    {:noreply, add_details_to_state(state)}
  end

  def handle_cast({:process_message, message}, state) do
    state = ensure_initialized(state)
    Logger.info("Got new message on server #{state.server_data.server_id}")
    {:noreply, state}
  end

  defp add_details_to_state(state) do
    cached_details = Db.Server.get_server_by_id(state.sid)
    server_data = case cached_details do
      {:none} ->
        update_server(state.sid)
      {:exists, srv} ->
        srv
    end

    Map.put(state, :server_data, server_data)
  end

  defp ensure_initialized(state) do
    case Map.has_key?(state, :server_data) do
      false ->
        #Initialization has not finished yet, make synchronous call now
        add_details_to_state(state)
      true ->
        #Initialization has already happened, exit.
        state
    end
  end

  defp update_server(sid) do
    case DiscordInterface.Server.get_server_details(sid) do
      {:error, err} ->
        Logger.warn(err)
      {:ok, server} ->
        Logger.info("Fetched server #{server["name"]}")
        server_obj = %Db.Server{server_id: server["id"], owner_id: server["owner_id"]}
        Db.Server.write_server(server_obj)
        server_obj
    end
  end
end
