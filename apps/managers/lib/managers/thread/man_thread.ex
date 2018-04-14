defmodule Managers.Thread.ThreadManager do
  use GenServer

  require Logger
  alias Managers.Thread.Command.Interpret

  @registry_name :conversation_thread_registry
  @process_lifetime_ms 86_400_000 #24 hours

  defstruct server_id: -1,
            channel_id: -1,
            user_id: -1,
            message_callback: nil

  #API
  def start_link(id) do
    GenServer.start_link(__MODULE__, [id], name: via_tuple(id))
  end

  def process_message(id, message) do
    GenServer.cast(via_tuple(id), {:process_message, message})
  end

  defp via_tuple(id) do
    {:via, Registry, {@registry_name, id}}
  end




  #SERVER
  def init([{sid, cid, uid}]) do
    GenServer.cast(self(), :get_server_details)
    {:ok, %__MODULE__{:server_id => sid,
                      :channel_id => cid,
                      :user_id => uid,
                      :message_callback => &Interpret.start_thread/2}}
  end
end
