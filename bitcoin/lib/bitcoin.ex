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
    {:ok, super_pid} = start_link(num_users - 1)
    update_agent(Supervisor.which_children(super_pid), agent_pid)

    begin(agent_pid, num_users)

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
    {private_keys, public_keys, public_addresses} = generate_keys(num_users, [], [], [])

    keys = %{
      "private_keys" => private_keys,
      "public_keys" => public_keys,
      "public_addresses" => public_addresses
    }

    users = create_users(num_users, num_users, keys, [])
    Supervisor.start_link(users, strategy: :one_for_one)
  end

  @doc """
  generates required number of triplets
  """
  def generate_keys(num_users, private_keys, public_keys, public_addresses) do
    if num_users >= 0 do
      {private_key, public_key, public_address} = KeyGenerator.everything()
      generate_keys(num_users - 1, private_keys ++ [private_key], public_keys ++ [public_key], public_addresses ++ [public_address])
    else
      {private_keys, public_keys, public_addresses}
    end
  end


  @doc """
  returns an array of users with initial state
  """
  def create_users(n, num_users, keys, users) do
    if n >= 0 do
      public_addresses = Map.get(keys, "public_addresses")
      {_, public_addresses} = List.pop_at(public_addresses, n)

      users = [
        %{
          id: n,
          start: {User, :start_link,
            [%{
             :wallet => %{
               :private_key => Map.get(keys, "private_keys") |> Enum.at(n),
               :public_key => Map.get(keys, "public_keys") |> Enum.at(n),
               :public_address => Map.get(keys, "public_addresses") |> Enum.at(n),
               :my_UTXOs => [],
             },
              :blockchain => [],
              :mempool => MapSet.new(),
              :id => n,
              :num_users => num_users,
              :public_addresses => public_addresses,
              :all_UTXOs => []
            }]
          }
        }
        | users]

      create_users(n-1, num_users, keys, users)
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

  @doc """

  """
  def begin(agent_pid, num_users) do
    satoshi = :rand.uniform(num_users) - 1
    satoshi_pid = Neighbors.get(agent_pid, satoshi)
    send satoshi_pid, {:genesis}
  end

end
