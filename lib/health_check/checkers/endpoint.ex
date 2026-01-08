defmodule HealthCheck.Checkers.Endpoint do
  @moduledoc false
  require Logger

  def check(config \\ []) do
    endpoint = config[:endpoint]

    if is_binary(endpoint) and endpoint != "" do
      perform_check(endpoint, config)
    else
      :ok
    end
  end

  defp perform_check(endpoint, config) do
    timeout = config[:timeout] || 5000

    try do
      case HTTPoison.get(endpoint, [], recv_timeout: timeout) do
        {:ok, %HTTPoison.Response{status_code: code}} when code < 500 ->
          :ok

        {:ok, %HTTPoison.Response{status_code: code}} ->
          Logger.error("Endpoint health check failed for #{endpoint}: status code #{code}")
          {:error, :endpoint_error}

        {:error, reason} ->
          Logger.error("Endpoint health check failed for #{endpoint}: #{inspect(reason)}")
          {:error, :endpoint_error}
      end
    rescue
      e ->
        Logger.error("Endpoint health check failed for #{endpoint}: #{inspect(e)}")
        {:error, :endpoint_exception}
    end
  end
end
