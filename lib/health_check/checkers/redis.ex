defmodule HealthCheck.Checkers.Redis do
  @moduledoc false
  require Logger

  def check(redis_conn_selector) when is_function(redis_conn_selector, 0) do
    case Redix.command(redis_conn_selector.(), ["PING"], timeout: 5000) do
      {:ok, "PONG"} ->
        :ok

      error ->
        Logger.error("Health check failed for Redis: #{inspect(error)}")
        {:error, :redis}
    end
  rescue
    e ->
      Logger.error("Health check failed for Redis: #{inspect(e)}")
      {:error, :redis}
  end
end
