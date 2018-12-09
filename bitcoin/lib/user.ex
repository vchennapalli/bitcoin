defmodule User do
  alias Block, as: B
  alias Transaction, as: T
  # alias Helper, as: H

  @moduledoc """
  contains the definitions and functions for wallet
  """
  use GenServer

  @first_tx_after 1000
  @create_second_block_after 2000
  @block_mining_rate 1500 # one per 1.5 secs
  @initiate_tx_range 100..600 # new tx initiated per a 0.1 to 0.6 secs

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
    Process.send_after(self(), :initiate_transaction, @first_tx_after)
    Process.send_after(self, :create_block, @create_second_block_after)
    {:ok, args}
  end


  def handle_info({:receive_transaction, transaction}, state) do
    state = T.receive_transaction(state, transaction)
    # IO.inspect new_state
    {:noreply, state}
  end

  def handle_info({:receive_block, block, height}, state) do
    new_state = B.receive(state, block, height)
    {:noreply, new_state}
  end

  def handle_info(:initiate_transaction, state) do
    # IO.inspect state
    Process.send_after(self(), :initiate_transaction, Enum.random(@initiate_tx_range))
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

  def handle_info(:create_block, state) do
    bc_size = length(state[:blockchain])
    max_blocks = state[:max_blocks]
    mempool_size = state[:mempool] |> map_size()

    new_state = 
    cond do
      bc_size == max_blocks ->
        parent = state[:parent]
        Process.send(parent, :close, [])
        state
      mempool_size >= 4 ->
        {state, block, height} = B.create(state)
        agent_pid = state[:agent_pid]
        neighbors = state[:public_addresses]
        IO.puts "Mined a new block, broadcasting it . ."
        broadcast_block(block, height, agent_pid, neighbors)
        Process.send_after(self(), :initiate_transaction, @block_mining_rate)
        state
      true ->
        Process.send_after(self(), :initiate_transaction, @block_mining_rate)
        state
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
