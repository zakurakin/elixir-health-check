defmodule HealthCheck.Checkers.Mongo do
  @moduledoc false
  require Logger

  def check(config \\ []) do
    topology_name = config[:topology_name] || config[:topology]

    cond do
      is_nil(topology_name) ->
        Logger.error("Mongo health check failed: topology is not configured")
        {:error, :mongo}

      not Code.ensure_loaded?(Mongo) ->
        Logger.error(
          "Mongo health check failed for #{inspect(topology_name)}: Mongo is not available"
        )

        {:error, topology_name}

      Process.whereis(topology_name) == nil ->
        Logger.error(
          "Mongo health check failed for #{inspect(topology_name)}: topology is not running"
        )

        {:error, topology_name}

      true ->
        do_check(topology_name)
    end
  end

  defp do_check(topology_name) do
    case Mongo.command(topology_name, ping: 1) do
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
end
