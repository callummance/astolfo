defmodule Managers.Channel.ManChannel do
  use GenServer

  require Logger

  alias Managers.Server.Supervisor
  @registry_name :channel_manager_registry
  @process_lifetime_ms 86_400_000 #24 hours

  #API
  def start_link(cid) do
    GenServer.start_link(__MODULE__, [cid], name: via_tuple(cid))
  end

  def process_message(id, message) do
    GenServer.cast(via_tuple(id), {:process_message, message})
  end

  defp via_tuple(channel_id) do
    {:via, Registry, {@registry_name, channel_id}}
  end


  #SERVER
  def init([cid]) do
    Logger.info("Thread started for channel #{cid}")
    GenServer.cast(self(), :get_channel_details)
    {:ok, %{:cid => cid}}
  end

  def handle_cast({:process_message, new_message}, state) do
    state = ensure_initialized(state)
    Logger.info("Got new message: #{new_message.content} from #{new_message.author.username}")
    {:noreply, state}
  end

  def handle_cast(:get_channel_details, state) do
    {:noreply, add_details_to_state(state)}
  end



  defp add_details_to_state(state) do
    cached_details = Db.Channel.get_channel_by_id(state.cid)
    channel_data = case cached_details do
      {:none} ->
        update_channel(state.cid)
      {:exists, chan} ->
        chan
    end

    Map.put(state, :chan_data, channel_data)
  end

  defp update_channel(cid) do
    case DiscordInterface.Channel.get_channel_details(cid) do
      {:error, err} ->
        Logger.warn(err)
      {:ok, chan} ->
        Logger.info("Fetched channel #{chan["name"]} (#{chan["id"]}) for guild id #{chan["guild_id"]}")
        channel_obj = case chan["type"] do
          0 -> #Guild Text
            #Try to fetch server data too
            get_server(chan["guild_id"])
            %Db.Channel{channel_id: chan["id"], server_id: chan["server_id"], channel_type: 0}
          1 -> #DM
            %Db.Channel{channel_id: chan["id"], channel_type: 1}
          2 -> #Guild Voice
            #Try to fetch server data too
            get_server(chan["guild_id"])
            %Db.Channel{channel_id: chan["id"], server_id: chan["server_id"], channel_type: 2}
          3 -> #Group DM
            %Db.Channel{channel_id: chan["id"], channel_type: 3}
          4 -> #Guild Category
            #Try to fetch server data too
            get_server(chan["guild_id"])
            %Db.Channel{channel_id: chan["id"], server_id: chan["server_id"], channel_type: 4}
        end
        Logger.info("Now writing channel data for channel #{channel_obj.channel_id} to database.")
        Db.Channel.write_channel(channel_obj)
        channel_obj
    end
  end

  defp ensure_initialized(state) do
    case Map.has_key?(state, :chan_data) do
      false ->
        #Initialization has not finished yet, make synchronous call now
        add_details_to_state(state)
      true ->
        #Initialization has already happened, exit.
        state
    end
  end

  defp get_server(sid) do
    Supervisor.find_or_create(sid)
  end

end
