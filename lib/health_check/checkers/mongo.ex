defmodule HealthCheck.Checkers.Mongo do
  @moduledoc false
  require Logger

  def check(config \\ []) do
    topology_name = config[:topology_name]

    if Code.ensure_loaded?(Mongo) and Process.whereis(topology_name) != nil do
      try do
        case Mongo.command(topology_name, [ping: 1]) do
          {:ok, _} ->
            :ok

          {:error, reason} ->
            Logger.error(
              "Mongo health check failed for #{inspect(topology_name)}: #{inspect(reason)}"
            )

            {:error, topology_name}
        end
      rescue
        e ->
          Logger.error("Mongo health check failed for #{inspect(topology_name)}: #{inspect(e)}")
          {:error, topology_name}
      catch
        kind, reason ->
          Logger.error(
            "Mongo health check failed for #{inspect(topology_name)}: #{inspect({kind, reason})}"
          )

          {:error, topology_name}
      end
    else
      :ok
    end
  end
end
