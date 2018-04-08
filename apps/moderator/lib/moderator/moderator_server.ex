defmodule Moderator.ModeratorServer do
  require Logger

  use GenServer

  def start_link(opts \\ []) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], opts)
  end

  def check_message(msg) do
    GenServer.call(:moderator_server, {:new_message, msg})
  end


  #Server implementation
  def init([]) do
    #TODO: Load wordlist, initialise message history
    {:ok, [[], []]}
  end

  def handle_call({:new_message, msg}, _from, [wordlist, recent_messages]) do
    Logger.info("Processing message: #{msg.content}")
    #TODO: Check message against word list
    #TODO: check message against word history to check for spamming
    #TODO: Save message to history
    {:reply, {:ok}, [wordlist, recent_messages]}
  end
end
