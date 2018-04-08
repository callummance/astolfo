defmodule Managers.ManServer do
  use GenServer

  require Logger

  #API
  def start_link(sid) do
    GenServer.start_link(__MODULE__, [sid], name: via_tuple(sid))
  end

  def process_message(sid, message) do
    {:ok, pid} = check_server(sid)
    process_server_message(pid, message)
  end

  def process_server_message(pid, message) do
    GenServer.cast(pid, {:process_message, message})
  end

  def get_server(sid) do
    check_server(sid)
  end

  defp check_server(sid) do
    gproc_name = {:n, :l, {:server_manager, sid}}
    case :gproc.where(gproc_name) do
      :undefined  -> 
        Logger.info("Starting thread for server #{sid}")
        pid = Supervisor.start_child(:manager_supervisor, [sid])
        :gproc.reg(gproc_name, pid)
        pid
      pid         -> pid
    end
  end

  defp via_tuple(server_id) do
    {:via, Registry, {:server_manager_registry, server_id}}
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
