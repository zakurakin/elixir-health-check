defmodule HealthCheck.Checkers.Mongo do
  @moduledoc false
  require Logger

  def check(topology_name) do
    if Code.ensure_loaded?(Mongo) do
      try do
        # Use ping command to check connectivity
        case Mongo.command(topology_name, %{ping: 1}) do
          {:ok, _} -> :ok
          {:error, reason} ->
            Logger.error("Mongo health check failed for #{inspect(topology_name)}: #{inspect(reason)}")
            {:error, topology_name}
        end
      rescue
        e ->
          Logger.error("Mongo health check failed for #{inspect(topology_name)}: #{inspect(e)}")
          {:error, topology_name}
      end
    else
      :ok
    end
  end
end
