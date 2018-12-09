defmodule User do
  alias Block, as: B
  alias Transaction, as: T
  # alias Helper, as: H

  @moduledoc """
  contains the definitions and functions for wallet
  """
  use GenServer

  @doc """
  first step
  """
  def start_link(status) do
    GenServer.start_link(__MODULE__, status)
  end

  @doc """
  initialize the process
  """
  def init(args) do
    Process.send_after(self(), :initiate_transaction, 1000)
    {:ok, args}
  end


  def handle_info({:receive_transaction, transaction}, state) do
    {new_state, possible_block, possible_height} = T.receive_transaction(state, transaction)
    if possible_block != nil do
      agent_pid = new_state[:agent_pid]
      neighbors = new_state[:public_addresses]
      IO.puts "Broadcasting a newly mined block . ."
      broadcast_block(possible_block, possible_height, agent_pid, neighbors)
    end
    # IO.inspect new_state
    {:noreply, new_state}
  end

  def handle_info({:receive_block, block, height}, state) do
    new_state = B.receive(state, block, height)
    {:noreply, new_state}
  end

  def handle_info(:initiate_transaction, state) do
    # IO.inspect state
    Process.send_after(self(), :initiate_transaction, Enum.random(100..600))
    {new_transaction, new_state} = T.initiate_transaction(state)
    if new_transaction != nil do
      # IO.inspect get_in(state, [:wallet, :public_address])
      neighbors = Map.get(new_state, :public_addresses)
      agent_pid = Map.get(new_state, :agent_pid)
      broadcast_transaction(new_transaction, agent_pid, neighbors)
      Process.send(self(), {:receive_transaction, new_transaction}, [])  
    end

    {:noreply, new_state}
  end

  def handle_info(:genesis, state) do
    {new_state, new_block, height} = B.create(state)
    neighbors = Map.get(state, :public_addresses)
    agent_pid = Map.get(state, :agent_pid)
    IO.puts "Broadcasting the genesis block . ."
    broadcast_block(new_block, height, agent_pid, neighbors)
    {:noreply, new_state}
  end

  @doc """
  sends the transaction to all the neighbors in the network
  """
  def broadcast_transaction(transaction, agent_pid, [neighbor | neighbors]) do
    neigh_pid = Neighbors.get(agent_pid, neighbor)
    Process.send(neigh_pid, {:receive_transaction, transaction}, [])
    broadcast_transaction(transaction, agent_pid, neighbors)
  end

  def broadcast_transaction(_, _, []) do
    true
  end

  @doc """
  sends the block to all the neighbors in the network
  """
  def broadcast_block(block, height, agent_pid, [neighbor | neighbors]) do
    neigh_pid = Neighbors.get(agent_pid, neighbor)
    Process.send(neigh_pid, {:receive_block, block, height}, [])
    broadcast_block(block, height, agent_pid, neighbors)
  end

  def broadcast_block(_, _, _, []) do
    true
  end

end
