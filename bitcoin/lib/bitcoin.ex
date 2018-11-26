defmodule Bitcoin do
  @moduledoc """
  main module from where the peerss are created
  """
  use Supervisor
  @doc """
  main function
  """
  def main do
    num_users = 2
    {:ok, agent_pid} = Neighbors.start_link(nil)
    {:ok, super_pid} = start_link(num_users)
    update_agent(Supervisor.which_children(super_pid), agent_pid)

  end

  @doc """
  init for Supervisor
  """
  def init([]) do
    nil
  end

  @doc """
  creates users in the peer-to-peer network
  """
  def start_link(num_users) do
    users = create_users(num_users, [])
    Supervisor.start_link(users, strategy: :one_for_one)
  end

  @doc """
  returns an array of users withi initial state
  """
  def create_users(n, users) do
    if n > 0 do
      users = [
        %{
          id: n,
          start: {User, :start_link,
            [%{
             :wallet => %{
               :private_key => nil,
               :public_key => nil,
               :public_address => nil,
               :UTXOs => [],
             },
              :blockchain => [],
              :mempool => MapSet.new(),
            }]
          }
        }
        | users]

      create_users(n-1, users)
    else
      users
    end
  end

  @doc """
  adds neighbors to the agent map
  """
  def update_agent([child | children], agent_pid) do
    {id, pid, _, _} = child

    Neighbors.put(agent_pid, id, pid)
    update_agent(children, agent_pid)
  end

  def update_agent([], _), do: nil

end
